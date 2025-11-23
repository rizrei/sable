defmodule SableWeb.PageController do
  use SableWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
