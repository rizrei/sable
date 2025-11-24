defmodule Sable.Plugs.Authenticate do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    case Sable.Repo.get_by(Sable.User, first_name: "Dima") do
      nil -> assign(conn, :current_user, nil)
      user -> assign(conn, :current_user, user)
    end
  end
end
