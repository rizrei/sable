defmodule Sable.SetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sable.Sets` context.
  """

  @doc """
  Generate a set.
  """
  def set_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        comment: "some comment"
      })

    {:ok, set} = Sable.Sets.create_set(scope, attrs)
    set
  end
end
