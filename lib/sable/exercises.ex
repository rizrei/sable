defmodule Sable.Exercises do
  @moduledoc """
  The Exercises context.
  """

  import Ecto.Query

  alias Sable.Exercises.Exercise
  alias Sable.Repo

  def subscribe_exercises, do: Phoenix.PubSub.subscribe(Sable.PubSub, "exercises")

  def broadcast_exercise(message),
    do: Phoenix.PubSub.broadcast(Sable.PubSub, "exercises", message)

  @doc """
  Returns the list of exercises.
  """
  def list_exercises(params) do
    Exercise
    |> order_by(asc: :title)
    |> limit(^params[:limit])
    |> Repo.all()
  end

  @doc """
  Gets a exercise by id.
  """
  def get_exercise(id), do: Repo.get(Exercise, id)

  @doc """
  Returns the list of exercises by search term.
  """
  def search(text) do
    Exercise
    |> where([t], ilike(t.title, ^"%#{text}%"))
    |> order_by(asc: :title)
    |> Repo.all()
  end

  def create_exercise(attrs \\ %{}) do
    with {:ok, exercise = %Exercise{}} <-
           %Exercise{}
           |> Exercise.changeset(attrs)
           |> Repo.insert() do
      broadcast_exercise({:created, exercise})
      {:ok, exercise}
    end
  end

  def change_exercise(%Exercise{} = exercise, attr \\ %{}) do
    Exercise.changeset(exercise, attr)
  end
end
