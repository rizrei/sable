defmodule Sable.Sets.Plot do
  import Ecto.Query

  alias Sable.Sets.Plot.Params
  alias Sable.Repo
  alias Sable.Sets.Set
  alias Sable.Accounts.User
  alias Sable.Exercises.Exercise
  alias Contex.{TimeScale, Dataset}

  def build(user, exercise, plot_params) do
    with {:ok, dataset} <- build_dataset(user, exercise, plot_params),
         {:ok, custom_x_scale} <- build_custom_x_scale(dataset) do
      Contex.Plot.new(dataset, plot_params.shape, plot_params.width, plot_params.height,
        custom_x_scale: custom_x_scale,
        smoothed: plot_params.smoothed
      )
      |> Contex.Plot.titles(build_title(plot_params), nil)
    end
  end

  def default_params(%Exercise{metrics: [hd | _]}), do: %Params{type: hd}

  defp build_dataset(%User{id: user_id}, %Exercise{id: exercise_id}, %Params{} = params) do
    Set
    |> where([s], s.inserted_at >= ^DateTime.shift(DateTime.utc_now(), [{params.period, -1}]))
    |> where([s], s.exercise_id == ^exercise_id)
    |> where([s], s.user_id == ^user_id)
    |> order_by(asc: :inserted_at)
    |> select([:inserted_at, :metrics])
    |> Repo.all()
    |> build_dataset_rows(params.type)
    |> Dataset.new()
    |> Dataset.title(params.type)
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

  def build_title(%Params{type: type}), do: to_string(type)
end
