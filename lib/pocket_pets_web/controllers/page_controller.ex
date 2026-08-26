defmodule PocketPetsWeb.PageController do
  use PocketPetsWeb, :controller

  def home(conn, _params) do
    render(conn, :home, ideas: PocketPets.DeployCopilot.sample_ideas())
  end

  def health(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
