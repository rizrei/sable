defmodule Sable.Factories.WorkoutTagFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def workout_tag_factory do
        %Sable.Workouts.WorkoutTag{
          workout: build(:workout),
          tag: build(:tag)
        }
      end
    end
  end
end
