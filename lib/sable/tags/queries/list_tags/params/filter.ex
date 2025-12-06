defmodule Sable.Tags.Queries.ListTags.Params.Filter do
  @moduledoc """
  Filtering parameters for query.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @typedoc """
  Struct of normalized filter parameters.
  """
  @type t :: %__MODULE__{
          search: String.t() | nil,
          user_id: [String.t()] | nil
        }

  @primary_key false
  embedded_schema do
    field :search, :string
    field :user_id, {:array, Ecto.UUID}
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:search, :user_id])
  end
end
