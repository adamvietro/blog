defmodule BlogWeb.CommentAuthorizationTest do
  use BlogWeb.ConnCase

  import Blog.AccountsFixtures
  import Blog.PostsFixtures
  import Blog.CommentsFixtures

  alias Blog.Comments

  describe "comment editing authorization" do
    test "user can edit their own comment", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      conn =
        conn
        |> log_in_user(user)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit",
          comment: %{content: "updated content", post_id: post.id}
        )

      assert redirected_to(conn) == ~p"/posts/#{post}/comments/"
      assert Comments.get_comment!(comment.id).content == "updated content"
    end

    test "user cannot edit another user's comment", %{conn: conn} do
      comment_owner = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: comment_owner.id)
      comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

      conn =
        conn
        |> log_in_user(other_user)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit", comment: %{content: "hacked content"})

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert redirected_to(conn) == ~p"/posts/#{post}"
      assert Comments.get_comment!(comment.id).content == comment.content
    end

    test "the post's author cannot edit someone else's comment on their own post", %{conn: conn} do
      post_author = user_fixture()
      commenter = user_fixture()
      post = post_fixture(user_id: post_author.id)
      comment = comment_fixture(user_id: commenter.id, post_id: post.id)

      conn =
        conn
        |> log_in_user(post_author)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit", comment: %{content: "edited by author"})

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert Comments.get_comment!(comment.id).content == comment.content
    end

    test "an admin who doesn't own the comment cannot edit it either", %{conn: conn} do
      comment_owner = user_fixture()
      admin = admin_fixture()
      post = post_fixture(user_id: comment_owner.id)
      comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

      conn =
        conn
        |> log_in_user(admin)
        |> put(~p"/posts/#{post}/comments/#{comment}/edit", comment: %{content: "admin edit"})

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert Comments.get_comment!(comment.id).content == comment.content
    end

    test "unauthenticated user cannot edit any comment", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      conn = put(conn, ~p"/posts/#{post}/comments/#{comment}/edit", comment: %{content: "anon"})

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "comment deletion authorization" do
    test "user can delete their own comment", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}/comments/#{comment}")

      assert redirected_to(conn) == ~p"/posts/#{post}/comments"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Comment deleted successfully"

      assert_raise Ecto.NoResultsError, fn ->
        Comments.get_comment!(comment.id)
      end
    end

    test "user cannot delete another user's comment", %{conn: conn} do
      comment_owner = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: comment_owner.id)
      comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

      conn = conn |> log_in_user(other_user) |> delete(~p"/posts/#{post}/comments/#{comment}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert redirected_to(conn) == ~p"/posts/#{post}"
      assert Comments.get_comment!(comment.id)
    end

    test "the post's author cannot delete someone else's comment on their own post", %{
      conn: conn
    } do
      post_author = user_fixture()
      commenter = user_fixture()
      post = post_fixture(user_id: post_author.id)
      comment = comment_fixture(user_id: commenter.id, post_id: post.id)

      conn = conn |> log_in_user(post_author) |> delete(~p"/posts/#{post}/comments/#{comment}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert Comments.get_comment!(comment.id)
    end

    test "an admin who doesn't own the comment cannot delete it either", %{conn: conn} do
      comment_owner = user_fixture()
      admin = admin_fixture()
      post = post_fixture(user_id: comment_owner.id)
      comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

      conn = conn |> log_in_user(admin) |> delete(~p"/posts/#{post}/comments/#{comment}")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "You can only edit or delete your own comments"

      assert Comments.get_comment!(comment.id)
    end

    test "unauthenticated user cannot delete any comment", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      comment = comment_fixture(user_id: user.id, post_id: post.id)

      conn = delete(conn, ~p"/posts/#{post}/comments/#{comment}")

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Comments.get_comment!(comment.id)
    end
  end
end
