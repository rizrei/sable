defmodule Sable.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sets" do
    embeds_one :metrics, Sable.SetMetrics, on_replace: :update

    belongs_to :user, Sable.Accounts.User
    belongs_to :exercise, Sable.Exercises.Exercise

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:user_id, :exercise_id])
    |> validate_required([:user_id, :exercise_id])
    |> cast_embed(:metrics, required: true)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:exercise_id)
  end
end
