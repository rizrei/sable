defmodule Sable.Factories.WorkoutExerciseFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def workout_exercise_factory do
        %Sable.Workouts.WorkoutExercise{
          workout: build(:workout),
          exercise: build(:exercise)
        }
      end
    end
  end
end
