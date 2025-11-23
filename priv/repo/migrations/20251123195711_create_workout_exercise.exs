defmodule Sable.Repo.Migrations.CreateWorkoutExercise do
  use Ecto.Migration

  def change do
    create table(:workout_exercise, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :workout_id, references(:workouts, on_delete: :delete_all, type: :uuid)
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:workout_exercise, [:workout_id])
    create index(:workout_exercise, [:exercise_id])
  end
end
