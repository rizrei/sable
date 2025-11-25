defmodule Sable.SetMetrics do
  @moduledoc """
  The SetMetrics embedded schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :rep, :integer
    field :weight, :integer
    field :distance, :integer
  end

  @doc false
  def changeset(metrics, attrs) do
    metrics
    |> cast(attrs, [:rep, :weight, :distance])
  end
end
