defmodule PocketPetsWeb.ErrorJSONTest do
  use PocketPetsWeb.ConnCase, async: true

  test "renders 404" do
    assert PocketPetsWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PocketPetsWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
