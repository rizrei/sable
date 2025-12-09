defmodule Sable.Workouts.WorkoutExercise do
  @moduledoc """
  The WorkoutExercise schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workout_exercise" do
    field :position, :integer, default: 0

    belongs_to :workout, Sable.Workouts.Workout
    belongs_to :exercise, Sable.Exercises.Exercise

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout_exercise, attrs) do
    workout_exercise
    |> cast(attrs, [:position, :workout_id, :exercise_id])
    |> validate_required([:position, :workout_id, :exercise_id])
  end
end
