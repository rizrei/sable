defmodule Sable.Workouts.Queries.ListWorkouts.Params do
  @moduledoc """
  Validates and normalizes parameters for Workouts query.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Sable.Workouts.Queries.ListWorkouts.Params.{Filter, OrderBy}

  @typedoc """
  Struct representing normalized parameters for `list_places/1`.

  Fields:
    * `limit` — query limit filter
    * `order_by` — order fields (see `OrderBy.t/0`)
    * `filter` — filtering rules (see `Filter.t/0`)
  """
  @type t :: %__MODULE__{
          limit: integer() | nil,
          offset: integer() | nil,
          order_by: OrderBy.t() | nil,
          filter: Filter.t() | nil
        }

  @typedoc """
  Raw input parameters.

  Example:

      %{
        limit: 5,
        order_by: %{title: :asc},
        filter: %{
          search: "some search term",
          tag_id: "e2834dd1-f44c-48b0-8fc9-e6087f9e19c2",
        }
      }
  """
  @type criteria :: %{
          optional(:limit) => integer(),
          optional(:offset) => integer(),
          optional(:order_by) => map(),
          optional(:filter) => map()
        }

  @primary_key false
  embedded_schema do
    field :limit, :integer
    field :offset, :integer

    embeds_one(:order_by, OrderBy)
    embeds_one(:filter, Filter)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:limit, :offset])
    |> validate_number(:limit, greater_than_or_equal_to: 1)
    |> validate_number(:offset, greater_than_or_equal_to: 0)
    |> cast_embed(:order_by, with: &OrderBy.changeset/2)
    |> cast_embed(:filter, with: &Filter.changeset/2)
  end
end
