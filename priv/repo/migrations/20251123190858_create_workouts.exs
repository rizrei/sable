defmodule Sable.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :author_id, references(:users, on_delete: :nilify_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:workouts, [:author_id])
  end
end
