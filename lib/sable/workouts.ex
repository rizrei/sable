defmodule Sable.Workouts do
  @moduledoc """
  The Workouts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Sable.Repo
  alias Sable.Workouts.Queries.ListWorkouts
  alias Sable.Workouts.Queries.ListWorkouts.Params
  alias Sable.Workouts.{UserWorkout, Workout}

  @doc """
  Returns the list of workouts.

  ## Examples

      iex> list_workouts()
      [%Workout{}, ...]

  """
  def list_workouts, do: Repo.all(Workout)
  def list_workouts(%Params{} = params), do: ListWorkouts.call(params) |> Repo.all()
  def list_workouts(_), do: list_workouts()

  @doc """
  Gets a single workout.

  Raises `Ecto.NoResultsError` if the Workout does not exist.

  ## Examples

      iex> get_workout!(123)
      %Workout{}

      iex> get_workout!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workout!(id), do: Repo.get!(Workout, id)

  @dialyzer {:nowarn_function, create_workout: 1}
  def create_workout(attrs) do
    Multi.new()
    |> Multi.insert(:workout, Workout.changeset(%Workout{}, attrs))
    |> Multi.insert(:user_workout, fn %{workout: %Workout{id: workout_id, author_id: user_id}} ->
      UserWorkout.changeset(%UserWorkout{}, %{user_id: user_id, workout_id: workout_id})
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a workout.

  ## Examples

      iex> update_workout(workout, %{field: new_value})
      {:ok, %Workout{}}

      iex> update_workout(workout, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workout(%Workout{} = workout, attrs) do
    workout
    |> Workout.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a workout.

  ## Examples

      iex> delete_workout(workout)
      {:ok, %Workout{}}

      iex> delete_workout(workout)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workout(%Workout{} = workout) do
    Repo.delete(workout)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workout changes.

  ## Examples

      iex> change_workout(workout)
      %Ecto.Changeset{data: %Workout{}}

  """
  def change_workout(%Workout{} = workout, attrs \\ %{}) do
    Workout.changeset(workout, attrs)
  end
end
