defmodule Sable.Repo.Migrations.CreateWorkoutTags do
  use Ecto.Migration

  def change do
    create table(:workout_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :workout_id, references(:workouts, on_delete: :delete_all, type: :uuid)
      add :tag_id, references(:tags, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:workout_tags, [:workout_id])
    create index(:workout_tags, [:tag_id])
  end
end
