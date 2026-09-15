defmodule BlogWeb.Plugs.TrackVisit do
  @moduledoc """
  Records a lightweight, privacy-conscious page view for the admin
  dashboard's visitor metrics (see `Blog.Analytics`).

  Only GET requests outside `/dev` are tracked. The visitor is identified by
  a hash of their IP and User-Agent — never the raw IP — so we can count
  unique visitors without storing anything personally identifying.

  Runs in a separate, unlinked process so a slow or failing insert never
  affects the page response.
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{method: "GET"} = conn, _opts) do
    if analytics_enabled?() and not String.starts_with?(conn.request_path, "/dev") do
      path = conn.request_path
      visitor_hash = visitor_hash(conn)

      Task.start(fn -> Blog.Analytics.track_visit(path, visitor_hash) end)
    end

    conn
  end

  def call(conn, _opts), do: conn

  defp analytics_enabled?, do: Application.get_env(:blog, :analytics_enabled, true)

  defp visitor_hash(conn) do
    ip = client_ip(conn)
    user_agent = conn |> get_req_header("user-agent") |> List.first() || ""

    :crypto.hash(:sha256, ip <> "|" <> user_agent)
    |> Base.encode16(case: :lower)
  end

  # Fly.io sits in front of the app as a reverse proxy, so conn.remote_ip is
  # Fly's internal proxy address, not the visitor's — Fly forwards the real
  # client IP in this header. Falls back to conn.remote_ip for local/dev.
  defp client_ip(conn) do
    case get_req_header(conn, "fly-client-ip") do
      [ip | _] -> ip
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
