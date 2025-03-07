defmodule BlogWeb.Post_TagControllerTest do
  use BlogWeb.ConnCase

  import Blog.Post_TagsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all post_tags", %{conn: conn} do
      conn = get(conn, ~p"/post_tags")
      assert html_response(conn, 200) =~ "Listing Post tags"
    end
  end

  describe "new post__tag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/post_tags/new")
      assert html_response(conn, 200) =~ "New Post  tag"
    end
  end

  describe "create post__tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/post_tags", post__tag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/post_tags/#{id}"

      conn = get(conn, ~p"/post_tags/#{id}")
      assert html_response(conn, 200) =~ "Post  tag #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/post_tags", post__tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post  tag"
    end
  end

  describe "edit post__tag" do
    setup [:create_post__tag]

    test "renders form for editing chosen post__tag", %{conn: conn, post__tag: post__tag} do
      conn = get(conn, ~p"/post_tags/#{post__tag}/edit")
      assert html_response(conn, 200) =~ "Edit Post  tag"
    end
  end

  describe "update post__tag" do
    setup [:create_post__tag]

    test "redirects when data is valid", %{conn: conn, post__tag: post__tag} do
      conn = put(conn, ~p"/post_tags/#{post__tag}", post__tag: @update_attrs)
      assert redirected_to(conn) == ~p"/post_tags/#{post__tag}"

      conn = get(conn, ~p"/post_tags/#{post__tag}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, post__tag: post__tag} do
      conn = put(conn, ~p"/post_tags/#{post__tag}", post__tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post  tag"
    end
  end

  describe "delete post__tag" do
    setup [:create_post__tag]

    test "deletes chosen post__tag", %{conn: conn, post__tag: post__tag} do
      conn = delete(conn, ~p"/post_tags/#{post__tag}")
      assert redirected_to(conn) == ~p"/post_tags"

      assert_error_sent 404, fn ->
        get(conn, ~p"/post_tags/#{post__tag}")
      end
    end
  end

  defp create_post__tag(_) do
    post__tag = post__tag_fixture()
    %{post__tag: post__tag}
  end
end
