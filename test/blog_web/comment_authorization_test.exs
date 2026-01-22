# defmodule BlogWeb.CommentAuthorizationTest do
#   use BlogWeb.ConnCase

#   import Blog.AccountsFixtures
#   import Blog.PostsFixtures
#   import Blog.CommentsFixtures

#   alias Blog.Comments
#   alias Blog.Repo

#   describe "comment editing authorization" do
#     test "user can edit their own comment", %{conn: conn} do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)
#       comment = comment_fixture(user_id: user.id, post_id: post.id)

#       update_attrs = %{content: "updated content"}

#       conn = log_in_user(conn, user)
#       conn = put(conn, ~p"/comments/#{comment.id}", comment: update_attrs)

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"

#       updated_comment = Comments.get_comment!(comment.id)
#       assert updated_comment.content == "updated content"
#     end

#     test "user cannot edit another user's comment", %{conn: conn} do
#       comment_owner = user_fixture()
#       other_user = user_fixture()
#       post = post_fixture(user_id: comment_owner.id)
#       comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

#       original_content = comment.content
#       update_attrs = %{content: "hacked content"}

#       conn = log_in_user(conn, other_user)
#       conn = put(conn, ~p"/comments/#{comment.id}", comment: update_attrs)

#       assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
#                "You can only edit your own comments"

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"

#       # Verify comment wasn't changed
#       unchanged_comment = Comments.get_comment!(comment.id)
#       assert unchanged_comment.content == original_content
#     end

#     test "admin cannot edit other users' comments (unless specifically allowed)", %{conn: conn} do
#       comment_owner = user_fixture()
#       admin = admin_fixture()
#       post = post_fixture(user_id: comment_owner.id)
#       comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

#       original_content = comment.content
#       update_attrs = %{content: "admin modified"}

#       conn = log_in_user(conn, admin)
#       conn = put(conn, ~p"/comments/#{comment.id}", comment: update_attrs)

#       # Change this expectation if admins SHOULD be able to edit
#       assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
#                "You can only edit your own comments"

#       # Verify comment wasn't changed
#       unchanged_comment = Comments.get_comment!(comment.id)
#       assert unchanged_comment.content == original_content
#     end

#     test "unauthenticated user cannot edit any comment", %{conn: conn} do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)
#       comment = comment_fixture(user_id: user.id, post_id: post.id)

#       update_attrs = %{content: "anonymous edit"}

#       conn = put(conn, ~p"/comments/#{comment.id}", comment: update_attrs)

#       assert redirected_to(conn) == ~p"/users/log_in"
#     end
#   end

#   describe "comment deletion authorization" do
#     test "user can delete their own comment", %{conn: conn} do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)
#       comment = comment_fixture(user_id: user.id, post_id: post.id)

#       conn = log_in_user(conn, user)
#       conn = delete(conn, ~p"/comments/#{comment.id}")

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"
#       assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Comment deleted"

#       assert_raise Ecto.NoResultsError, fn ->
#         Comments.get_comment!(comment.id)
#       end
#     end

#     test "user cannot delete another user's comment", %{conn: conn} do
#       comment_owner = user_fixture()
#       other_user = user_fixture()
#       post = post_fixture(user_id: comment_owner.id)
#       comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

#       conn = log_in_user(conn, other_user)
#       conn = delete(conn, ~p"/comments/#{comment.id}")

#       assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
#                "You can only delete your own comments"

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"

#       # Verify comment still exists
#       assert Comments.get_comment!(comment.id)
#     end

#     test "post author can delete comments on their own post", %{conn: conn} do
#       post_author = user_fixture()
#       commenter = user_fixture()
#       post = post_fixture(user_id: post_author.id)
#       comment = comment_fixture(user_id: commenter.id, post_id: post.id)

#       conn = log_in_user(conn, post_author)
#       conn = delete(conn, ~p"/comments/#{comment.id}")

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"
#       assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Comment deleted"

#       assert_raise Ecto.NoResultsError, fn ->
#         Comments.get_comment!(comment.id)
#       end
#     end

#     test "admin can delete any comment", %{conn: conn} do
#       comment_owner = user_fixture()
#       admin = admin_fixture()
#       post = post_fixture(user_id: comment_owner.id)
#       comment = comment_fixture(user_id: comment_owner.id, post_id: post.id)

#       conn = log_in_user(conn, admin)
#       conn = delete(conn, ~p"/comments/#{comment.id}")

#       assert redirected_to(conn) == ~p"/posts/#{post.id}"
#       assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Comment deleted"

#       assert_raise Ecto.NoResultsError, fn ->
#         Comments.get_comment!(comment.id)
#       end
#     end

#     test "unauthenticated user cannot delete any comment", %{conn: conn} do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)
#       comment = comment_fixture(user_id: user.id, post_id: post.id)

#       conn = delete(conn, ~p"/comments/#{comment.id}")

#       assert redirected_to(conn) == ~p"/users/log_in"

#       # Verify comment still exists
#       assert Comments.get_comment!(comment.id)
#     end
#   end

#   describe "comment validation" do
#     test "cannot create empty comment" do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)

#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: "",
#           post_id: post.id,
#           user_id: user.id
#         })

#       assert %{content: ["can't be blank"]} = errors_on(changeset)
#     end

#     test "cannot create comment with only whitespace" do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)

#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: "   ",
#           post_id: post.id,
#           user_id: user.id
#         })

#       assert %{content: ["can't be blank"]} = errors_on(changeset)
#     end

#     test "cannot create extremely long comment" do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)

#       # Assuming max length is 10000 characters
#       too_long = String.duplicate("a", 10001)

#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: too_long,
#           post_id: post.id,
#           user_id: user.id
#         })

#       assert "should be at most 10000 character(s)" in errors_on(changeset).content
#     end

#     test "comment content should sanitize HTML to prevent XSS" do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)

#       malicious_content = "<script>alert('XSS')</script>Hello"

#       {:ok, comment} =
#         Comments.create_comment(%{
#           content: malicious_content,
#           post_id: post.id,
#           user_id: user.id
#         })

#       # The content should be sanitized or escaped
#       # This test assumes you're using a library like HtmlSanitizeEx
#       refute comment.content =~ "<script>"
#       # Or it should be HTML escaped
#       # assert comment.content =~ "&lt;script&gt;"
#     end

#     test "cannot comment on non-existent post" do
#       user = user_fixture()

#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: "Comment on nothing",
#           post_id: -1,
#           user_id: user.id
#         })

#       assert %{post_id: ["does not exist"]} = errors_on(changeset)
#     end

#     test "cannot create comment without user_id" do
#       post = post_fixture(user_id: user_fixture().id)

#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: "Anonymous comment",
#           post_id: post.id
#         })

#       assert %{user_id: ["can't be blank"]} = errors_on(changeset)
#     end
#   end

#   describe "commenting on deleted posts" do
#     test "cannot comment on a deleted post" do
#       user = user_fixture()
#       post = post_fixture(user_id: user.id)
#       post_id = post.id

#       # Delete the post
#       Blog.Posts.delete_post(post)

#       # Try to create comment
#       {:error, changeset} =
#         Comments.create_comment(%{
#           content: "Comment on deleted post",
#           post_id: post_id,
#           user_id: user.id
#         })

#       assert %{post_id: ["does not exist"]} = errors_on(changeset)
#     end
#   end
# end
