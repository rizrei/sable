defmodule Sable.Repo.Migrations.CreateExerciseMetrics do
  use Ecto.Migration

  def change do
    create table(:exercise_metrics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :uuid)
      add :metric_id, references(:metrics, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:exercise_metrics, [:exercise_id])
    create index(:exercise_metrics, [:metric_id])
  end
end
