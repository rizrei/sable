defmodule Sable.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query

  alias Sable.Repo
  alias Sable.Tags.Tag

  def list_tags do
    Tag |> order_by(asc: :title) |> Repo.all()
  end

  def search(text) do
    Tag
    |> where([t], ilike(t.title, ^"%#{text}%"))
    |> order_by(asc: :title)
    |> Repo.all()
  end

  def change_tag(%Tag{} = tag, attrs \\ %{}), do: Tag.changeset(tag, attrs)
end
