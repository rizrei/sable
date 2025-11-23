defmodule Sable.Factories.WorkoutFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def workout_factory do
        %Sable.Workouts.Workout{
          title: sequence(:title, &"title_#{&1}"),
          description: Faker.Lorem.paragraph(),
          author: build(:user)
        }
      end
    end
  end
end
