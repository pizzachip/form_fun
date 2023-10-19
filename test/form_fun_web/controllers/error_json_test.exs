defmodule FormFunWeb.ErrorJSONTest do
  use FormFunWeb.ConnCase, async: true

  test "renders 404" do
    assert FormFunWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert FormFunWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
