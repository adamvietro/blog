defmodule BlogWeb.Plugs.TrackVisitTest do
  use BlogWeb.ConnCase, async: false

  alias Blog.Analytics
  alias BlogWeb.Plugs.TrackVisit

  setup do
    # The plug spawns an unlinked Task to write the visit, which needs a
    # sandbox connection of its own — share this test's connection with
    # any process for the duration of the test rather than fighting
    # per-process checkout.
    Ecto.Adapters.SQL.Sandbox.mode(Blog.Repo, {:shared, self()})
    Application.put_env(:blog, :analytics_enabled, true)

    on_exit(fn ->
      Application.put_env(:blog, :analytics_enabled, false)
      Ecto.Adapters.SQL.Sandbox.mode(Blog.Repo, :manual)
    end)

    :ok
  end

  defp wait_for_visit_count(expected, retries \\ 20)

  defp wait_for_visit_count(expected, 0) do
    flunk("expected #{expected} visit(s) to be recorded, got #{Blog.Repo.aggregate(Analytics.Visit, :count)}")
  end

  defp wait_for_visit_count(expected, retries) do
    if Blog.Repo.aggregate(Analytics.Visit, :count) == expected do
      :ok
    else
      Process.sleep(10)
      wait_for_visit_count(expected, retries - 1)
    end
  end

  test "records a visit for a plain GET request", %{conn: conn} do
    conn = conn |> Map.put(:method, "GET") |> Map.put(:request_path, "/posts")

    TrackVisit.call(conn, [])
    wait_for_visit_count(1)

    assert [visit] = Blog.Repo.all(Analytics.Visit)
    assert visit.path == "/posts"
  end

  test "does not record non-GET requests", %{conn: conn} do
    conn = conn |> Map.put(:method, "POST") |> Map.put(:request_path, "/posts")

    result = TrackVisit.call(conn, [])
    Process.sleep(20)

    assert result == conn
    assert Blog.Repo.aggregate(Analytics.Visit, :count) == 0
  end

  test "does not record requests under /dev", %{conn: conn} do
    conn = conn |> Map.put(:method, "GET") |> Map.put(:request_path, "/dev/dashboard")

    TrackVisit.call(conn, [])
    Process.sleep(20)

    assert Blog.Repo.aggregate(Analytics.Visit, :count) == 0
  end

  test "does not record anything when analytics is disabled", %{conn: conn} do
    Application.put_env(:blog, :analytics_enabled, false)
    conn = conn |> Map.put(:method, "GET") |> Map.put(:request_path, "/posts")

    TrackVisit.call(conn, [])
    Process.sleep(20)

    assert Blog.Repo.aggregate(Analytics.Visit, :count) == 0
  end

  test "prefers the fly-client-ip header over conn.remote_ip", %{conn: conn} do
    conn1 =
      conn
      |> Map.put(:method, "GET")
      |> Map.put(:request_path, "/a")
      |> Plug.Conn.put_req_header("fly-client-ip", "203.0.113.5")
      |> Plug.Conn.put_req_header("user-agent", "TestAgent")

    conn2 =
      conn
      |> Map.put(:method, "GET")
      |> Map.put(:request_path, "/b")
      |> Plug.Conn.put_req_header("fly-client-ip", "203.0.113.5")
      |> Plug.Conn.put_req_header("user-agent", "TestAgent")
      |> Map.put(:remote_ip, {9, 9, 9, 9})

    TrackVisit.call(conn1, [])
    TrackVisit.call(conn2, [])
    wait_for_visit_count(2)

    [visit1, visit2] = Blog.Repo.all(Analytics.Visit)

    # Same fly-client-ip + same user-agent should hash identically even
    # though conn.remote_ip differs between the two requests.
    assert visit1.visitor_hash == visit2.visitor_hash
  end
end
