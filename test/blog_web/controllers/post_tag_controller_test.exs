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

  describe "new post_tag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/post_tags/new")
      assert html_response(conn, 200) =~ "New Post  tag"
    end
  end

  describe "create post_tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/post_tags", post_tag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/post_tags/#{id}"

      conn = get(conn, ~p"/post_tags/#{id}")
      assert html_response(conn, 200) =~ "Post  tag #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/post_tags", post_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post  tag"
    end
  end

  describe "edit post_tag" do
    setup [:create_post_tag]

    test "renders form for editing chosen post_tag", %{conn: conn, post_tag: post_tag} do
      conn = get(conn, ~p"/post_tags/#{post_tag}/edit")
      assert html_response(conn, 200) =~ "Edit Post  tag"
    end
  end

  describe "update post_tag" do
    setup [:create_post_tag]

    test "redirects when data is valid", %{conn: conn, post_tag: post_tag} do
      conn = put(conn, ~p"/post_tags/#{post_tag}", post_tag: @update_attrs)
      assert redirected_to(conn) == ~p"/post_tags/#{post_tag}"

      conn = get(conn, ~p"/post_tags/#{post_tag}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, post_tag: post_tag} do
      conn = put(conn, ~p"/post_tags/#{post_tag}", post_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post  tag"
    end
  end

  describe "delete post_tag" do
    setup [:create_post_tag]

    test "deletes chosen post_tag", %{conn: conn, post_tag: post_tag} do
      conn = delete(conn, ~p"/post_tags/#{post_tag}")
      assert redirected_to(conn) == ~p"/post_tags"

      assert_error_sent 404, fn ->
        get(conn, ~p"/post_tags/#{post_tag}")
      end
    end
  end

  defp create_post_tag(_) do
    post_tag = post_tag_fixture()
    %{post_tag: post_tag}
  end
end
