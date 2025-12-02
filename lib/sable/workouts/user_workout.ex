defmodule Sable.Workouts.UserWorkout do
  @moduledoc """
  The UserWorkout schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_workouts" do
    belongs_to :user, Sable.Accounts.User
    belongs_to :workout, Sable.Workouts.Workout

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_workout, attrs) do
    user_workout
    |> cast(attrs, [:user_id, :workout_id])
    |> validate_required([:user_id, :workout_id])
  end
end
