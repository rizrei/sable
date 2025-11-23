defmodule Sable.Factories.ExerciseMetricFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def exercise_metric_factory do
        %Sable.ExerciseMetric{
          exercise: build(:push_up_exercise),
          metric: build(:reps_metric)
        }
      end
    end
  end
end
