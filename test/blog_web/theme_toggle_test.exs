defmodule BlogWeb.ThemeToggleTest do
  use BlogWeb.ConnCase, async: true

  test "GET / renders the light/dark/system theme toggle and the pre-paint theme script", %{
    conn: conn
  } do
    conn = get(conn, "/")
    html = html_response(conn, 200)

    assert html =~ ~s(data-theme-choice="light")
    assert html =~ ~s(data-theme-choice="system")
    assert html =~ ~s(data-theme-choice="dark")
    assert html =~ "localStorage.getItem(\"theme\")"
  end
end
