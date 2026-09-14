defmodule BlogWeb.PageControllerTest do
  use BlogWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hey, I'm Adam."
  end
end
