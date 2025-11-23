defmodule Sable.User do
  @moduledoc """
  The Tag schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  @phone_regex ~r/^(\+7)\s?\(?\d{3}\)?[\s-]?\d{3}[\s-]?\d{2}[\s-]?\d{2}$/
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :phone])
    |> validate_required([:first_name, :last_name, :phone])
    |> validate_format(:phone, @phone_regex)
    |> unique_constraint(:phone)
  end
end
