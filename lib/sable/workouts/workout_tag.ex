defmodule Sable.Workouts.WorkoutTag do
  @moduledoc """
  The WorkoutTag schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workout_tags" do
    belongs_to :workout, Sable.Workouts.Workout
    belongs_to :tag, Sable.Tags.Tag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout_tags, attrs) do
    workout_tags
    |> cast(attrs, [:tag_id, :workout_id])
    |> validate_required([:tag_id, :workout_id])
  end
end
