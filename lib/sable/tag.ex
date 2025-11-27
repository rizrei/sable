defmodule Sable.Tag do
  @moduledoc """
  The Tag schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field :title, :string
    field :color, :string, default: "#00FFFF"

    has_many :workout_tags, Sable.Workouts.WorkoutTag
    has_many :workouts, through: [:workout_tags, :workout]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title, :color])
    |> validate_required([:title])
    |> validate_format(:color, ~r/^#(?:[0-9a-fA-F]{3}){1,2}$/)
  end
end
