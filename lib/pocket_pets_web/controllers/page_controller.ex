defmodule PocketPetsWeb.PageController do
  use PocketPetsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
