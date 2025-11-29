defmodule Sable.Workouts.Workout do
  @moduledoc """
  The Workout schema.
  """

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias Sable.Workouts.{WorkoutExercise, WorkoutTag}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workouts" do
    field :title, :string
    field :description, :string
    field :tag_ids, {:array, :map}, virtual: true

    belongs_to :author, Sable.Accounts.User

    has_many :workout_exercises, WorkoutExercise,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :exercises, through: [:workout_exercises, :exercise]

    many_to_many :tags, Sable.Tag, join_through: WorkoutTag, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :description, :author_id])
    |> put_assoc_tags(attrs)
    |> cast_assoc(:workout_exercises,
      with: &workout_exercise_changeset/2,
      sort_param: :workout_exercises_sort,
      drop_param: :workout_exercises_drop,
      required: false
    )
    |> validate_required([:title, :description, :author_id])
    |> foreign_key_constraint(:author_id)
  end

  defp workout_exercise_changeset(workout_exercise, attrs) do
    workout_exercise
    |> cast(attrs, [:exercise_id, :position])
    |> validate_required([:exercise_id, :position])
  end

  defp put_assoc_tags(changeset, %{"tag_ids" => tag_ids}) do
    {uuid_list, string_list} = Enum.split_with(tag_ids, &match?({:ok, _}, Ecto.UUID.cast(&1)))
    tags = Sable.Repo.all(from t in Sable.Tag, where: t.id in ^uuid_list)
    new_tags = Enum.map(string_list, &%Sable.Tag{title: &1})
    put_assoc(changeset, :tags, new_tags ++ tags)
  end

  defp put_assoc_tags(changeset, _), do: changeset
end
