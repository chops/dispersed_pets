defmodule PocketPetsWeb.PetLiveTest do
  use PocketPetsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "switching demo pets keeps each pet's state", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/demo")

    view
    |> element("button[aria-label='Feed']")
    |> render_click()

    view
    |> element("button[phx-value-pet='byte']")
    |> render_click()

    view
    |> element("button[phx-value-pet='noodle']")
    |> render_click()

    assert render(view) =~ ">12</span>"
  end

  test "a dead pet shows restart controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/play")

    for _tick <- 1..60 do
      send(view.pid, :tick)
    end

    html = render(view)
    assert html =~ "Restart"
    assert html =~ "disabled"

    view
    |> element(".revive-button")
    |> render_click()

    refute render(view) =~ "Restart"
  end
end
