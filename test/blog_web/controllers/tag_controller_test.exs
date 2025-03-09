defmodule BlogWeb.TagControllerTest do
  use BlogWeb.ConnCase

  import Blog.TagsFixtures

  @create_attrs %{name: "some tag"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get(conn, ~p"/tags")
      assert html_response(conn, 200) =~ "Listing Tags"
    end
  end

  describe "new tag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/tags/new")
      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "create tag" do
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/tags", tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tag"
    end

    test "creates new tag with valid data" , %{conn: conn} do
      conn = post(conn, ~p"/tags", tag: @create_attrs)
      assert redirected_to(conn) == ~p"/tags/"
    end
  end

  describe "delete tag" do
    setup [:create_tag]

    test "deletes chosen tag", %{conn: conn, tag: tag} do
      conn = delete(conn, ~p"/tags/#{tag}")
      assert redirected_to(conn) == ~p"/tags"

      assert_error_sent 404, fn ->
        get(conn, ~p"/tags/#{tag}")
      end
    end
  end

  defp create_tag(_) do
    tag = tag_fixture()
    %{tag: tag}
  end
end
