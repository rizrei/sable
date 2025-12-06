defmodule Sable.Tags.Queries.ListTags.Params.OrderBy do
  @moduledoc """
  Sorting parameters for query.

  Each sortable field may be `:asc` or `:desc`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @typedoc """
  Struct of normalized sorting parameters.
  """
  @type t :: %__MODULE__{title: :asc | :desc}

  @primary_key false
  embedded_schema do
    field :title, Ecto.Enum, values: [:asc, :desc]
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    cast(schema, attrs, [:title])
  end
end
