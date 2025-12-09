defmodule Sable.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Sable.Repo

  use Sable.Factories.{
    UserFactory
    # ExerciseFactory,
    # TagFactory,
    # WorkoutFactory,
    # WorkoutTagFactory,
    # WorkoutExerciseFactory
  }
end
