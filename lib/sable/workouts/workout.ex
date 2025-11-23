defmodule Sable.Workouts.Workout do
  @moduledoc """
  The Workout schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workouts" do
    field :title, :string
    field :description, :string

    belongs_to :author, Sable.User

    has_many :workout_tags, Sable.Workouts.WorkoutTag
    has_many :workout_exercises, Sable.Workouts.WorkoutExercise
    has_many :tags, through: [:workout_tags, :tag]
    has_many :exercises, through: [:workout_exercises, :exercise]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :description, :user_id])
    |> validate_required([:title, :description, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
