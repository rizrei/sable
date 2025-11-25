defmodule Sable.Exercises do
  @moduledoc """
  The Exercises context.
  """

  alias Sable.Exercises.Exercise
  alias Sable.Repo

  @doc """
  Gets a exercise by id.
  """
  def get_exercise(id), do: Repo.get(Exercise, id)
end
