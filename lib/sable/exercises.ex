defmodule Sable.Exercises do
  @moduledoc """
  The Exercises context.
  """

  import Ecto.Query

  alias Sable.Exercises.Exercise
  alias Sable.Repo

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
end
