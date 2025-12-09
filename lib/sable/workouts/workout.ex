defmodule Sable.Workouts.Workout do
  @moduledoc """
  The Workout schema.
  """

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias Sable.Accounts.User
  alias Sable.{Repo, Tags}
  alias Sable.Tags.Tag
  alias Sable.Workouts.{UserWorkout, WorkoutExercise, WorkoutTag}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workouts" do
    field :title, :string
    field :description, :string
    field :tag_ids, {:array, :map}, virtual: true

    belongs_to :author, User

    has_many :user_workouts, UserWorkout

    has_many :workout_exercises, WorkoutExercise,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :exercises, through: [:workout_exercises, :exercise]
    has_many :users, through: [:user_workouts, :user]

    many_to_many :tags, Tag, join_through: WorkoutTag, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :description, :author_id])
    |> put_assoc_tags(attrs)
    |> cast_assoc(:workout_exercises, workout_exercises_assoc_opts())
    |> validate_required([:title, :author_id])
    |> foreign_key_constraint(:author_id)
  end

  defp put_assoc_tags(changeset, %{"tag_ids" => tag_ids}) do
    {uuid_list, string_list} = Enum.split_with(tag_ids, &match?({:ok, _}, Ecto.UUID.cast(&1)))
    tags_list = Repo.all(from t in Tag, where: t.id in ^uuid_list)

    tags =
      string_list
      |> Enum.map(&Tags.change_tag(%Tag{title: &1}))
      |> Enum.concat(tags_list)

    put_assoc(changeset, :tags, tags)
  end

  defp put_assoc_tags(changeset, _), do: changeset

  defp workout_exercises_assoc_opts do
    [
      with: &workout_exercise_changeset/3,
      sort_param: :workout_exercises_sort,
      drop_param: :workout_exercises_drop,
      required: false
    ]
  end

  defp workout_exercise_changeset(workout_exercise, attrs, position) do
    workout_exercise
    |> cast(attrs, [:exercise_id])
    |> put_change(:position, position + 1)
    |> validate_required([:exercise_id, :position])
  end
end
