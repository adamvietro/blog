defmodule Blog.AnalyticsTest do
  use Blog.DataCase

  alias Blog.Analytics
  alias Blog.Analytics.Visit

  import Blog.AccountsFixtures

  describe "track_visit/2" do
    test "records a visit with the given path and visitor hash" do
      assert {:ok, %Visit{} = visit} = Analytics.track_visit("/posts/1", "somehash")

      assert visit.path == "/posts/1"
      assert visit.visitor_hash == "somehash"
    end

    test "requires both path and visitor_hash" do
      assert {:error, changeset} = Analytics.track_visit(nil, nil)
      assert %{path: ["can't be blank"], visitor_hash: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "count_users/0" do
    test "returns the total number of registered users" do
      assert Analytics.count_users() == 0

      user_fixture()
      user_fixture()

      assert Analytics.count_users() == 2
    end
  end

  describe "count_unique_visitors_since/1" do
    test "counts distinct visitor hashes, not raw visit rows" do
      Analytics.track_visit("/", "visitor-a")
      Analytics.track_visit("/posts", "visitor-a")
      Analytics.track_visit("/posts/1", "visitor-b")

      since = DateTime.add(DateTime.utc_now(), -1, :day)

      assert Analytics.count_unique_visitors_since(since) == 2
    end

    test "excludes visits recorded before the given time" do
      {:ok, old_visit} = Analytics.track_visit("/", "old-visitor")
      Analytics.track_visit("/", "recent-visitor")

      # Backdate via update_all, since Repo.insert would just re-autogenerate
      # inserted_at regardless of what we set on the struct beforehand.
      old_time = DateTime.utc_now() |> DateTime.add(-10, :day) |> DateTime.truncate(:second)

      from(v in Visit, where: v.id == ^old_visit.id)
      |> Repo.update_all(set: [inserted_at: old_time])

      since = DateTime.add(DateTime.utc_now(), -1, :day)

      assert Analytics.count_unique_visitors_since(since) == 1
    end

    test "returns zero when there are no visits" do
      since = DateTime.add(DateTime.utc_now(), -1, :day)

      assert Analytics.count_unique_visitors_since(since) == 0
    end
  end
end
