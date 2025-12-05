defmodule Sable.Sets.Plot do
  @moduledoc """
  The Plot embedded schema.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Sable.Accounts.User
  alias Sable.Repo
  alias Sable.Exercises.Exercise
  alias Sable.Sets.Set
  alias Contex.{PointPlot, LinePlot, TimeScale, Dataset, Plot}

  @type_values %{
    "Reps" => :rep,
    "Weight" => :weight,
    "Distance" => :distance,
    "Duration" => :duration,
    "Capacity" => :capacity,
    "Speed" => :speed
  }

  @shape_values %{
    "Line" => LinePlot,
    "Point" => PointPlot
  }

  @period_values [:year, :month, :week, :day]

  @primary_key false
  embedded_schema do
    field :type, Ecto.Enum, values: Map.values(@type_values)
    field :shape, Ecto.Enum, values: Map.values(@shape_values), default: LinePlot
    field :period, Ecto.Enum, values: @period_values, default: :month
    field :smoothed, :boolean, default: false
    field :width, :integer, default: 600
    field :height, :integer, default: 400

    field :exercise, :map
    field :user, :map
    field :sets_list, {:array, :map}
    field :plot, :map
  end

  @doc false
  def sets_list_changeset(%__MODULE__{} = plot, attrs \\ %{}) do
    plot
    |> cast(attrs, [:sets_list])
    |> validate_required([:sets_list])
    |> put_plot()
  end

  @doc false
  def changeset(%__MODULE__{} = plot, attrs \\ %{}) do
    c_keys = [:type, :shape, :period, :smoothed, :width, :height, :exercise, :user, :sets_list]
    r_keys = [:shape, :period, :smoothed, :width, :height, :exercise, :user]

    plot
    |> cast(attrs, c_keys)
    |> validate_required(r_keys)
    |> maybe_put_type
    |> maybe_put_sets_list()
    |> put_plot()
  end

  def shape_options, do: @shape_values

  def type_options, do: @type_values

  def type_options(%__MODULE__{exercise: %Exercise{metrics: metrics}}) do
    metrics = metrics |> maybe_speed() |> maybe_capacity()

    Enum.filter(@type_values, fn {_k, v} -> v in metrics end)
  end

  defp maybe_speed(metrics) do
    if is_list(metrics) and :distance in metrics and :duration in metrics do
      [:speed | metrics]
    else
      metrics
    end
  end

  defp maybe_capacity(metrics) do
    if is_list(metrics) and :weight in metrics and :rep in metrics do
      [:capacity | metrics]
    else
      metrics
    end
  end

  defp maybe_put_type(changeset) do
    case get_field(changeset, :type) do
      nil ->
        put_change(changeset, :type, get_field(changeset, :exercise) |> Map.get(:metrics) |> hd())

      _ ->
        changeset
    end
  end

  defp maybe_put_sets_list(changeset) do
    with %Exercise{id: exercise_id} <- get_field(changeset, :exercise),
         %User{id: user_id} <- get_field(changeset, :user),
         period <- get_field(changeset, :period) do
      sets =
        Set
        |> where([s], s.inserted_at >= ^DateTime.shift(DateTime.utc_now(), [{period, -1}]))
        |> where([s], s.exercise_id == ^exercise_id)
        |> where([s], s.user_id == ^user_id)
        |> order_by(asc: :inserted_at)
        |> select([:id, :inserted_at, :metrics])
        |> Repo.all()

      put_change(changeset, :sets_list, sets)
    else
      _ -> changeset
    end
  end

  def put_plot(changeset) do
    with {:ok, dataset} <- build_dataset(changeset),
         {:ok, custom_x_scale} <- build_custom_x_scale(dataset) do
      plot =
        Plot.new(
          dataset,
          get_field(changeset, :shape),
          get_field(changeset, :width),
          get_field(changeset, :height),
          custom_x_scale: custom_x_scale,
          smoothed: get_field(changeset, :smoothed)
        )
        |> Plot.titles(build_title(changeset), nil)

      put_change(changeset, :plot, plot)
    else
      _ -> put_change(changeset, :plot, nil)
    end
  end

  defp build_dataset(changeset) do
    type = get_field(changeset, :type)

    changeset
    |> get_field(:sets_list)
    |> build_dataset_rows(type)
    |> Dataset.new()
    |> Dataset.title(type)
    |> case do
      %Dataset{data: []} -> {:error, :empty_dataset}
      dataset -> {:ok, dataset}
    end
  end

  defp build_dataset_rows(sets, :capacity) do
    Enum.map(sets, &{&1.inserted_at, &1.metrics.rep * &1.metrics.weight})
  end

  defp build_dataset_rows(sets, :speed) do
    Enum.map(sets, &{&1.inserted_at, &1.metrics.distance / &1.metrics.duration})
  end

  defp build_dataset_rows(sets, type) do
    Enum.map(sets, &{&1.inserted_at, Map.get(&1.metrics, type)})
  end

  defp build_custom_x_scale(%Dataset{data: data}) do
    {date_min, _} = List.first(data)
    {date_max, _} = List.last(data)

    {:ok, TimeScale.domain(TimeScale.new(), date_min, date_max)}
  end

  def build_title(changeset), do: changeset |> get_field(:type) |> to_string()
end
