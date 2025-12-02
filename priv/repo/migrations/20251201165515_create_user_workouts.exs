defmodule Sable.Repo.Migrations.CreateUserWorkouts do
  use Ecto.Migration

  def change do
    create table(:user_workouts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :workout_id, references(:workouts, on_delete: :delete_all, type: :uuid), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_workouts, [:workout_id])
    create index(:user_workouts, [:user_id])
  end
end
