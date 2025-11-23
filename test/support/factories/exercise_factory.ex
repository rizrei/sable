defmodule Sable.Factories.ExerciseFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Sable.Exercise

      def exercise_factory, do: %Exercise{title: sequence(:title, &"title_#{&1}")}
      def barbell_bench_press_exercise_factory, do: %Exercise{title: "Barbell bench press"}
      def push_up_exercise_factory, do: %Exercise{title: "Push-up"}
    end
  end
end
