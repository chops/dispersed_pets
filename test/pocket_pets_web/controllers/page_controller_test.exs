defmodule PocketPetsWeb.PageControllerTest do
  use PocketPetsWeb.ConnCase

  test "GET /healthz", %{conn: conn} do
    conn = get(conn, ~p"/healthz")
    assert json_response(conn, 200) == %{"status" => "ok"}
  end
end
