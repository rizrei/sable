defmodule Sable.Exercises.Exercise do
  @moduledoc """
  The Metric schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "exercises" do
    field :title, :string

    has_many :exercise_metrics, Sable.Exercises.ExerciseMetric
    has_many :workout_exercises, Sable.Workouts.WorkoutExercise
    has_many :metrics, through: [:exercise_metrics, :metric]
    has_many :workouts, through: [:workout_exercises, :workout]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
