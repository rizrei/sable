defmodule Sable.Workouts.WorkoutExercise do
  @moduledoc """
  The WorkoutExercise schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workout_exercise" do
    belongs_to :workout, Sable.Workouts.Workout
    belongs_to :exercise, Sable.Exercises.Exercise

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout_exercise, attrs) do
    workout_exercise
    |> cast(attrs, [:workout_id, :exercise_id])
    |> validate_required([:workout_id, :exercise_id])
  end
end
