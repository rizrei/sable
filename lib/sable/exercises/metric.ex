defmodule Sable.Exercises.Metric do
  @moduledoc """
  The Metric schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "metrics" do
    field :title, :string
    field :unit, :string

    has_many :exercise_metrics, Sable.Exercises.ExerciseMetric
    has_many :exercises, through: [:exercise_metrics, :exercise]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:title, :unit])
    |> validate_required([:title, :unit])
  end
end
