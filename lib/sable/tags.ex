defmodule Sable.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query

  alias Sable.Accounts.User
  alias Sable.Repo
  alias Sable.Tags.Tag

  def list_tags do
    Tag |> order_by(asc: :title) |> Repo.all()
  end

  def list_tags(%User{id: user_id}) do
    Tag
    |> join(:inner, [t], w in assoc(t, :workouts))
    |> join(:inner, [_t, w], uw in assoc(w, :user_workouts))
    |> where([_t, _w, uw], uw.user_id == ^user_id)
    |> order_by(asc: :title)
    |> distinct(true)
    |> Repo.all()
  end

  def list_tags(_), do: list_tags()

  def search(text) do
    Tag
    |> where([t], ilike(t.title, ^"%#{text}%"))
    |> order_by(asc: :title)
    |> Repo.all()
  end

  def change_tag(%Tag{} = tag, attrs \\ %{}), do: Tag.changeset(tag, attrs)
end
