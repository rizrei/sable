defmodule Sable.Sets do
  @moduledoc """
  The Sets context.
  """

  import Ecto.Query, warn: false

  alias Sable.Accounts.Scope
  alias Sable.Repo
  alias Sable.Sets.Set

  @doc """
  Subscribes to scoped notifications about any set changes.

  The broadcasted messages match the pattern:

    * {:created, %Set{}}
    * {:updated, %Set{}}
    * {:deleted, %Set{}}

  """
  def subscribe_sets(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Sable.PubSub, "user:#{key}:sets")
  end

  defp broadcast_set(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Sable.PubSub, "user:#{key}:sets", message)
  end

  @doc """
  Returns the list of sets.

  ## Examples

      iex> list_sets(scope)
      [%Set{}, ...]

  """
  def list_sets(%Scope{user: %{id: user_id}}, exercise_id) do
    Set
    |> where(user_id: ^user_id, exercise_id: ^exercise_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single set.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set!(scope, 123)
      %Set{}

      iex> get_set!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_set!(%Scope{} = scope, id) do
    Repo.get_by!(Set, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a set.

  ## Examples

      iex> create_set(scope, %{field: value})
      {:ok, %Set{}}

      iex> create_set(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_set(scope, attrs) do
    with {:ok, set = %Set{}} <-
           %Set{}
           |> Set.changeset(attrs)
           |> Repo.insert() do
      broadcast_set(scope, {:created, set})
      {:ok, set}
    end
  end

  @doc """
  Deletes a set.

  ## Examples

      iex> delete_set(scope, set)
      {:ok, %Set{}}

      iex> delete_set(scope, set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_set(%Scope{} = scope, %Set{} = set) do
    true = set.user_id == scope.user.id

    with {:ok, set = %Set{}} <-
           Repo.delete(set) do
      broadcast_set(scope, {:deleted, set})
      {:ok, set}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking set changes.

  ## Examples

      iex> change_set(scope, set)
      %Ecto.Changeset{data: %Set{}}

  """
  def change_set(%Set{} = set, attrs \\ %{}) do
    Set.changeset(set, attrs)
  end
end
