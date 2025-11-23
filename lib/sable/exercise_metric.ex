defmodule Sable.ExerciseMetric do
  @moduledoc """
  The ExerciseMetric schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Sable.{Exercise, Metric}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "exercise_metrics" do
    belongs_to :exercise, Exercise
    belongs_to :metric, Metric

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise_metric, attrs) do
    exercise_metric
    |> cast(attrs, [:exercise_id, :metric_id])
    |> validate_required([:exercise_id, :metric_id])
    |> foreign_key_constraint(:exercise_id)
    |> foreign_key_constraint(:metric_id)
  end
end
