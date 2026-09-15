defmodule BlogWeb.ErrorHTMLTest do
  use BlogWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders a themed 404 page" do
    html = render_to_string(BlogWeb.ErrorHTML, "404", "html", [])

    assert html =~ "404"
    assert html =~ "page not found"
    assert html =~ "Back home"
  end

  test "renders a themed 500 page" do
    html = render_to_string(BlogWeb.ErrorHTML, "500", "html", [])

    assert html =~ "500"
    assert html =~ "internal server error"
    assert html =~ "Back home"
  end

  test "falls back to plain text for a status with no template" do
    assert render_to_string(BlogWeb.ErrorHTML, "403", "html", []) == "Forbidden"
  end

  test "GET on an unmatched route returns the themed 404 page", %{conn: conn} do
    conn = get(conn, "/this-page-does-not-exist")

    assert html_response(conn, 404) =~ "Back home"
  end
end
