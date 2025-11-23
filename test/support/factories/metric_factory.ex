defmodule Sable.Factories.MetricFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Sable.Metric

      def reps_metric_factory, do: %Metric{title: "Reps", unit: "quantity"}
      def weight_metric_factory, do: %Metric{title: "Weight", unit: "kg"}
      def distance_metric_factory, do: %Metric{title: "Distance", unit: "meter"}
    end
  end
end
