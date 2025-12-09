defmodule Sable.SetMetrics do
  @moduledoc """
  The SetMetrics embedded schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :rep, :integer
    field :weight, :integer
    field :distance, :integer
    field :duration, :integer
  end

  @doc false
  def changeset(metrics, attrs) do
    metrics
    |> cast(attrs, [:rep, :weight, :distance, :duration])
  end
end
