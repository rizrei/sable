defmodule Sable.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query

  alias Sable.Repo
  alias Sable.Tags.Tag
  alias Sable.Tags.Queries.ListTags
  alias Sable.Tags.Queries.ListTags.Params

  def list_tags, do: Repo.all(Tag)
  def list_tags(%Params{} = params), do: ListTags.call(params) |> Repo.all()
  def list_tags(_), do: list_tags()

  def change_tag(%Tag{} = tag, attrs \\ %{}), do: Tag.changeset(tag, attrs)
end
