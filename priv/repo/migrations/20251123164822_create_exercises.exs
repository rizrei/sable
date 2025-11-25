defmodule Sable.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :metrics, {:array, :string}, default: []

      timestamps(type: :utc_datetime)
    end

    create index(:exercises, [:title])
  end
end
