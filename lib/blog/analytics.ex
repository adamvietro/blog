defmodule Blog.Analytics do
  @moduledoc """
  The Analytics context: lightweight page-view tracking used to power the
  admin dashboard's user/visitor metrics.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Accounts.User
  alias Blog.Analytics.Visit

  @doc """
  Records a single page view.

  `visitor_hash` should already be a hash (not a raw IP) — see
  `BlogWeb.Plugs.TrackVisit`, which computes it.
  """
  def track_visit(path, visitor_hash) do
    %Visit{}
    |> Visit.changeset(%{path: path, visitor_hash: visitor_hash})
    |> Repo.insert()
  end

  @doc """
  Returns the total number of registered users.
  """
  def count_users do
    Repo.aggregate(User, :count)
  end

  @doc """
  Returns the number of distinct visitors (by hashed IP+User-Agent) recorded
  since the given `DateTime`.
  """
  def count_unique_visitors_since(%DateTime{} = since) do
    Visit
    |> where([v], v.inserted_at >= ^since)
    |> select([v], v.visitor_hash)
    |> distinct(true)
    |> Repo.aggregate(:count)
  end
end
