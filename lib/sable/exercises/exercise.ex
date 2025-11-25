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
    field :metrics, {:array, Ecto.Enum}, values: [:rep, :weight, :distance]

    has_many :sets, Sable.Sets.Set
    has_many :workout_exercises, Sable.Workouts.WorkoutExercise
    has_many :workouts, through: [:workout_exercises, :workout]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:title, :metrics])
    |> validate_required([:title, :metrics])
  end
end
