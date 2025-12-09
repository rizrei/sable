defmodule Sable.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :metrics, {:array, :string}, default: []
      add :author_id, references(:users, on_delete: :nilify_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:exercises, [:title])
  end
end
