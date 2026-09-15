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

    test "an unauthenticated visitor is redirected to log in", %{conn: conn} do
      conn = get(conn, ~p"/tags")
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "an admin sees the list of tags", %{conn: conn} do
      tag = tag_fixture(name: "a listed tag")
      conn = conn |> log_in_user(admin_fixture()) |> get(~p"/tags")

      assert html_response(conn, 200) =~ tag.name
    end
  end

  describe "show" do
    setup [:create_tag]

    test "an admin can view a single tag", %{conn: conn, tag: tag} do
      conn = conn |> log_in_user(admin_fixture()) |> get(~p"/tags/#{tag}")

      assert html_response(conn, 200) =~ tag.name
    end

    test "a non-admin cannot view a tag", %{conn: conn, tag: tag} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/tags/#{tag}")
      assert redirected_to(conn) == ~p"/"
    end

    test "an unauthenticated visitor is redirected to log in", %{conn: conn, tag: tag} do
      conn = get(conn, ~p"/tags/#{tag}")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "new tag" do
    test "renders form", %{conn: conn} do
      user = admin_fixture()
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/tags/new")
      assert html_response(conn, 200) =~ "New Tag"
    end

    test "a non-admin cannot reach the form", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/tags/new")
      assert redirected_to(conn) == ~p"/"
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

    test "a non-admin cannot create a tag", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> post(~p"/tags", tag: @create_attrs)
      assert redirected_to(conn) == ~p"/"
      assert Blog.Tags.list_tags() == []
    end
  end

  describe "edit tag" do
    setup [:create_tag]

    test "renders the edit form pre-filled with the tag's name", %{conn: conn, tag: tag} do
      conn = conn |> log_in_user(admin_fixture()) |> get(~p"/tags/#{tag}/edit")

      response = html_response(conn, 200)
      assert response =~ "Edit Tag"
      assert response =~ tag.name
    end

    test "a non-admin cannot reach the edit form", %{conn: conn, tag: tag} do
      conn = conn |> log_in_user(user_fixture()) |> get(~p"/tags/#{tag}/edit")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "update tag" do
    setup [:create_tag]

    test "updates the tag with valid data", %{conn: conn, tag: tag} do
      conn =
        conn
        |> log_in_user(admin_fixture())
        |> put(~p"/tags/#{tag}", tag: %{name: "renamed"})

      assert redirected_to(conn) == ~p"/tags/#{tag}"
      assert Blog.Tags.get_tag!(tag.id).name == "renamed"
    end

    test "renders errors when the new data is invalid", %{conn: conn, tag: tag} do
      conn =
        conn
        |> log_in_user(admin_fixture())
        |> put(~p"/tags/#{tag}", tag: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Tag"
      assert Blog.Tags.get_tag!(tag.id).name == tag.name
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

    test "a non-admin cannot delete a tag", %{conn: conn, tag: tag} do
      conn = conn |> log_in_user(user_fixture()) |> delete(~p"/tags/#{tag}")
      assert redirected_to(conn) == ~p"/"
      assert Blog.Tags.get_tag!(tag.id)
    end
  end

  describe "search" do
    test "shows only posts that carry the searched tag", %{conn: conn} do
      admin = admin_fixture()
      tag = tag_fixture(name: "elixir")
      other_tag = tag_fixture(name: "rust")

      matching_post =
        Blog.PostsFixtures.post_fixture(user_id: admin.id, title: "Elixir Post")

      Posts.update_post(matching_post, %{}, [tag])

      other_post = Blog.PostsFixtures.post_fixture(user_id: admin.id, title: "Rust Post")
      Posts.update_post(other_post, %{}, [other_tag])

      conn = get(conn, ~p"/tags/search", tag: tag.id)

      response = html_response(conn, 200)
      assert response =~ "Elixir Post"
      refute response =~ "Rust Post"
    end

    test "shows an empty state when no posts carry the tag", %{conn: conn} do
      tag = tag_fixture(name: "unused")

      response = get(conn, ~p"/tags/search", tag: tag.id) |> html_response(200)

      assert response =~ "No posts matched this tag."
    end

    test "renders the tag picker when no tag is chosen yet", %{conn: conn} do
      tag_fixture(name: "pickable")

      response = get(conn, ~p"/tags/search") |> html_response(200)

      assert response =~ "Search by tag"
      assert response =~ "pickable"
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
      tag_names: "#{tag1.name}, #{tag2.name}"
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
