defmodule PocketPetsWeb.PlanController do
  use PocketPetsWeb, :controller

  alias PocketPets.DeployCopilot

  def create(conn, params) do
    case DeployCopilot.plan(params) do
      {:ok, plan} ->
        json(conn, %{plan: plan})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(reason)})
    end
  end
end
