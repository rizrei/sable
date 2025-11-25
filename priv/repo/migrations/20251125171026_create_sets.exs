defmodule Sable.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :exercise_id, references(:exercises, on_delete: :delete_all, type: :uuid)
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)
      add :metrics, :map, default: %{}, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sets, [:exercise_id])
    create index(:sets, [:user_id])
  end
end
