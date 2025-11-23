defmodule Sable.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :unit, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
