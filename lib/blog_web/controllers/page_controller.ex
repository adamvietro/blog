defmodule BlogWeb.PageController do
  use BlogWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/posts")
    else
      render(conn, :home, layout: false)
    end
  end
end
