defmodule Sable.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Sable.Repo

  use Sable.Factories.{
    ExerciseFactory,
    TagFactory,
    UserFactory,
    WorkoutFactory,
    WorkoutTagFactory,
    WorkoutExerciseFactory
  }
end
