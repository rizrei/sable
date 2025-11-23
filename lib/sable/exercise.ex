defmodule Sable.Exercise do
  @moduledoc """
  The Metric schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "exercises" do
    field :title, :string

    has_many :exercise_metrics, Sable.ExerciseMetric
    has_many :metrics, through: [:exercise_metrics, :metric]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
