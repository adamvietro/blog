defmodule BlogWeb.PageControllerTest do
  use BlogWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hey, I'm Adam."
  end

  test "non-post pages use the site-wide social preview defaults, not a post's", %{conn: conn} do
    response = get(conn, ~p"/") |> html_response(200)

    assert response =~ ~s(property="og:title" content="Home Page")
    assert response =~
             ~s(property="og:description" content="Blog Site to keep track of my programming Journey.")

    assert response =~ ~s(property="og:image" content="https://media2.dev.to/)
    # Regression: og:type used to be hardcoded to "article" on every page,
    # including this one.
    assert response =~ ~s(property="og:type" content="website")
    refute response =~ "article:published_time"
    # Regression: twitter:card used to be set to an image URL instead of a
    # card-type string, which would have kept Twitter from rendering a card
    # at all.
    assert response =~ ~s(name="twitter:card" content="summary_large_image")
  end
end
