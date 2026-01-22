defmodule BlogWeb.TagControllerTest do
  use BlogWeb.ConnCase

  import Blog.TagsFixtures
  import Blog.AccountsFixtures
  import Blog.TagsFixtures

  alias Blog.Posts
  alias Blog.Repo

  @create_attrs %{name: "some tag"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "not an admin rerouted", %{conn: conn} do
      conn = get(conn, ~p"/tags")
      assert html_response(conn, 302) =~ "You are being"
    end
  end

  describe "new tag" do
    test "renders form", %{conn: conn} do
      user = admin_fixture()
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/tags/new")
      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "create tag" do
    test "renders errors when data is invalid", %{conn: conn} do
      user = admin_fixture()
      conn = log_in_user(conn, user)
      conn = post(conn, ~p"/tags", tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tag"
    end

    test "creates new tag with valid data", %{conn: conn} do
      user = admin_fixture()
      conn = log_in_user(conn, user)
      conn = post(conn, ~p"/tags", tag: @create_attrs)
      assert redirected_to(conn) == ~p"/tags"
    end
  end

  describe "delete tag" do
    setup [:create_tag]

    test "deletes chosen tag", %{conn: conn, tag: tag} do
      user = admin_fixture()
      conn = log_in_user(conn, user)

      conn = delete(conn, ~p"/tags/#{tag}")
      assert redirected_to(conn) == ~p"/tags"
    end
  end

  test "create post with tags", %{conn: conn} do
    # Arrange: Setup the necessary data
    user = admin_fixture()
    conn = log_in_user(conn, user)

    tag1 = tag_fixture(name: "tag 1 name")
    tag2 = tag_fixture(name: "tag 2 name")

    create_attrs = %{
      content: "some content",
      title: "some title",
      visible: true,
      published_on: Date.utc_today(),
      user_id: user.id,
      tag_ids: [tag1.id, tag2.id]
    }

    # Act: send the HTTP POST request
    conn = post(conn, ~p"/posts", post: create_attrs)

    # Assert: Verify the response is redirected and that the post is created with tags.
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == ~p"/posts/#{id}"

    post = Posts.get_post!(id) |> Repo.preload([:tags])

    assert post.tags == [tag1, tag2]
  end

  defp create_tag(_) do
    tag = tag_fixture()
    %{tag: tag}
  end
end
