defmodule Sable.Sets.PlotParams do
  @moduledoc """
  The plot embedded schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :type, Ecto.Enum, values: [:rep, :weight, :distance, :duration, :capacity]
    field :shape, Ecto.Enum, values: [Contex.PointPlot, Contex.LinePlot]
    field :period, Ecto.Enum, values: [:year, :month, :week, :day]
    field :title, :string
    field :smoothed, :boolean, default: true
    field :width, :integer, default: 600
    field :height, :integer, default: 400
    field :exercise, :map
    field :dataset, :map
    field :custom_x_scale, :map

    # embeds_one :exercise, Sable.Exercises.Exercise
    # embeds_one :dataset, Contex.Dataset
  end

  @doc false
  def changeset(plot_params, attrs \\ %{}) do
    plot_params
    |> cast(attrs, [:type, :shape, :period, :exercise])
    # |> cast_embed(:exercise, required: true)
    |> validate_required([:type, :shape, :period, :exercise])
    |> put_dataset()
    |> put_title()
    |> put_custom_x_scale()
  end

  defp put_title(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp put_title(changeset) do
    put_change(changeset, :title, get_field(changeset, :type) |> to_string())
  end

  defp put_custom_x_scale(changeset) do
    dataset = get_field(changeset, :dataset)
    {date_min, min_v} = List.first(dataset.data)
    {date_max, max_v} = List.last(dataset.data)

    put_change(
      changeset,
      :custom_x_scale,
      Contex.TimeScale.domain(Contex.TimeScale.new(), date_min, date_max)
    )
  end

  defp put_dataset(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp put_dataset(%Ecto.Changeset{} = changeset) do
    %{period: period, exercise: exercise, type: type} = Ecto.Changeset.apply_changes(changeset)

    dataset =
      exercise
      |> sets(period)
      |> build_dataset_rows(type)
      # |> Contex.Dataset.new(["x", "y"])
      |> Contex.Dataset.new()
      |> Contex.Dataset.title(type)

    put_change(changeset, :dataset, dataset)
  end

  import Ecto.Query
  alias Sable.Exercises.Exercise
  alias Sable.Sets.Set
  alias Sable.Repo

  defp sets(%Exercise{id: exercise_id}, period) do
    Set
    |> where([s], s.inserted_at >= ^DateTime.shift(DateTime.utc_now(), [{period, -1}]))
    |> where([s], s.exercise_id == ^exercise_id)
    |> order_by(asc: :inserted_at)
    |> select([:inserted_at, :metrics])
    |> Repo.all()
  end

  def build_dataset_rows(sets, :capacity) do
    Enum.map(sets, &{&1.inserted_at, &1.metrics.rep * &1.metrics.weight})
  end

  def build_dataset_rows(sets, type) do
    Enum.map(sets, &{&1.inserted_at, Map.get(&1.metrics, type)})
  end
end
