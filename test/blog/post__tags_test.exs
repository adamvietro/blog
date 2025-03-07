defmodule Blog.Post_TagsTest do
  use Blog.DataCase

  alias Blog.Post_Tags

  describe "post_tags" do
    alias Blog.Post_Tags.Post_Tag

    import Blog.Post_TagsFixtures

    @invalid_attrs %{}

    test "list_post_tags/0 returns all post_tags" do
      post__tag = post__tag_fixture()
      assert Post_Tags.list_post_tags() == [post__tag]
    end

    test "get_post__tag!/1 returns the post__tag with given id" do
      post__tag = post__tag_fixture()
      assert Post_Tags.get_post__tag!(post__tag.id) == post__tag
    end

    test "create_post__tag/1 with valid data creates a post__tag" do
      valid_attrs = %{}

      assert {:ok, %Post_Tag{} = post__tag} = Post_Tags.create_post__tag(valid_attrs)
    end

    test "create_post__tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Post_Tags.create_post__tag(@invalid_attrs)
    end

    test "update_post__tag/2 with valid data updates the post__tag" do
      post__tag = post__tag_fixture()
      update_attrs = %{}

      assert {:ok, %Post_Tag{} = post__tag} = Post_Tags.update_post__tag(post__tag, update_attrs)
    end

    test "update_post__tag/2 with invalid data returns error changeset" do
      post__tag = post__tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Post_Tags.update_post__tag(post__tag, @invalid_attrs)
      assert post__tag == Post_Tags.get_post__tag!(post__tag.id)
    end

    test "delete_post__tag/1 deletes the post__tag" do
      post__tag = post__tag_fixture()
      assert {:ok, %Post_Tag{}} = Post_Tags.delete_post__tag(post__tag)
      assert_raise Ecto.NoResultsError, fn -> Post_Tags.get_post__tag!(post__tag.id) end
    end

    test "change_post__tag/1 returns a post__tag changeset" do
      post__tag = post__tag_fixture()
      assert %Ecto.Changeset{} = Post_Tags.change_post__tag(post__tag)
    end
  end
end
