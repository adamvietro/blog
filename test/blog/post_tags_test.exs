defmodule Blog.Post_TagsTest do
  use Blog.DataCase

  alias Blog.Post_Tags

  describe "post_tags" do
    alias Blog.PostTags.PostTag

    import Blog.Post_TagsFixtures

    @invalid_attrs %{}

    test "list_post_tags/0 returns all post_tags" do
      post_tag = post_tag_fixture()
      assert Post_Tags.list_post_tags() == [post_tag]
    end

    test "get_post_tag!/1 returns the post_tag with given id" do
      post_tag = post_tag_fixture()
      assert Post_Tags.get_post_tag!(post_tag.id) == post_tag
    end

    test "create_post_tag/1 with valid data creates a post_tag" do
      valid_attrs = %{}

      assert {:ok, %Post_Tag{} = post_tag} = Post_Tags.create_post_tag(valid_attrs)
    end

    test "create_post_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Post_Tags.create_post_tag(@invalid_attrs)
    end

    test "update_post_tag/2 with valid data updates the post_tag" do
      post_tag = post_tag_fixture()
      update_attrs = %{}

      assert {:ok, %Post_Tag{} = post_tag} = Post_Tags.update_post_tag(post_tag, update_attrs)
    end

    test "update_post_tag/2 with invalid data returns error changeset" do
      post_tag = post_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Post_Tags.update_post_tag(post_tag, @invalid_attrs)
      assert post_tag == Post_Tags.get_post_tag!(post_tag.id)
    end

    test "delete_post_tag/1 deletes the post_tag" do
      post_tag = post_tag_fixture()
      assert {:ok, %Post_Tag{}} = Post_Tags.delete_post_tag(post_tag)
      assert_raise Ecto.NoResultsError, fn -> Post_Tags.get_post_tag!(post_tag.id) end
    end

    test "change_post_tag/1 returns a post_tag changeset" do
      post_tag = post_tag_fixture()
      assert %Ecto.Changeset{} = Post_Tags.change_post_tag(post_tag)
    end
  end
end
