defmodule Sable.Workouts.Workout do
  @moduledoc """
  The Workout schema.
  """

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias Sable.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workouts" do
    field :title, :string
    field :description, :string

    belongs_to :author, Sable.User

    has_many :workout_exercises, Sable.Workouts.WorkoutExercise, on_replace: :delete
    has_many :workout_tags, Sable.Workouts.WorkoutTag, on_replace: :delete
    has_many :tags, through: [:workout_tags, :tag]
    has_many :exercises, through: [:workout_exercises, :exercise]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :description, :author_id])
    |> cast_assoc(:workout_tags,
      with: &workout_tag_changeset/2,
      sort_param: :workout_tags_sort,
      drop_param: :workout_tags_drop,
      required: false
    )
    |> cast_assoc(:workout_exercises,
      with: &workout_exercise_changeset/2,
      sort_param: :workout_exercises_sort,
      drop_param: :workout_exercises_drop,
      required: false
    )
    |> validate_required([:title, :description, :author_id])
    |> foreign_key_constraint(:author_id)
  end

  defp workout_tag_changeset(workout_tag, attrs) do
    workout_tag
    |> cast(attrs, [:tag_id])
    |> validate_required([:tag_id])
  end

  defp workout_exercise_changeset(workout_exercise, attrs) do
    workout_exercise
    |> cast(attrs, [:exercise_id, :position])
    |> validate_required([:exercise_id])
  end
end
