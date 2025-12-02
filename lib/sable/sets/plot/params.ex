defmodule Sable.Sets.Plot.Params do
  @moduledoc """
  The plot embedded schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Sable.Exercises.Exercise
  alias Contex.{PointPlot, LinePlot}

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
  end

  @doc false
  def changeset(plot_params, attrs \\ %{}) do
    plot_params
    |> cast(attrs, [:type, :shape, :period, :smoothed, :width, :height])
    |> validate_required([:type, :shape, :period, :smoothed, :width, :height])
  end

  def shape_options, do: @shape_values

  def type_options(%Exercise{metrics: metrics}) do
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
end
