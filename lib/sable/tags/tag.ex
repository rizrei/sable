defmodule Sable.Tags.Tag do
  @moduledoc """
  The Tag schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tags" do
    field :title, :string
    field :color, :string

    has_many :workout_tags, Sable.Workouts.WorkoutTag
    has_many :workouts, through: [:workout_tags, :workout]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title, :color])
    |> maybe_put_random_color()
    |> validate_required([:title, :color])
    |> validate_format(:color, ~r/^#(?:[0-9a-fA-F]{3}){1,2}$/)
  end

  defp maybe_put_random_color(changeset) do
    case get_field(changeset, :color) do
      nil -> put_change(changeset, :color, random_color())
      _ -> changeset
    end
  end

  defp random_color do
    "#" <> Base.encode16(:crypto.strong_rand_bytes(3), case: :lower)
  end
end
