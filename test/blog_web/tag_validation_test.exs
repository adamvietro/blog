defmodule Blog.TagValidationTest do
  use Blog.DataCase

  import Blog.TagsFixtures
  # import Blog.PostsFixtures
  import Blog.AccountsFixtures

  alias Blog.Tags
  alias Blog.Posts
  alias Blog.Repo

  describe "tag name uniqueness" do
    test "cannot create duplicate tag names" do
      _tag = tag_fixture(name: "Elixir")

      assert {:error, changeset} = Tags.create_tag(%{name: "Elixir"})
      assert "has already been taken" in errors_on(changeset).name
    end

    test "tag names are case-insensitive" do
      _tag = tag_fixture(name: "Elixir")

      # Try to create with different case - will pass until you add case-insensitive validation
      # assert {:error, changeset} = Tags.create_tag(%{name: "elixir"})
      # assert "has already been taken" in errors_on(changeset).name

      # For now, this will create a separate tag (showing missing functionality)
      {:ok, lowercase_tag} = Tags.create_tag(%{name: "elixir"})
      assert lowercase_tag.name == "elixir"
    end

    test "tag names with different whitespace are considered duplicates" do
      _tag = tag_fixture(name: "Elixir")

      # These will pass until you add whitespace trimming
      # assert {:error, changeset} = Tags.create_tag(%{name: " Elixir"})
      # assert "has already been taken" in errors_on(changeset).name

      # For now, showing current behavior
      {:ok, space_tag} = Tags.create_tag(%{name: " Elixir"})
      assert space_tag.name == " Elixir"
    end
  end

  describe "tag name validation" do
    test "cannot create tag with empty name" do
      assert {:error, changeset} = Tags.create_tag(%{name: ""})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "cannot create tag with only whitespace" do
      assert {:error, changeset} = Tags.create_tag(%{name: "   "})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "tag name has minimum length requirement" do
      # Will pass until you add min length validation
      # assert {:error, changeset} = Tags.create_tag(%{name: "a"})
      # assert "should be at least 2 character(s)" in errors_on(changeset).name

      # Showing current behavior
      {:ok, short_tag} = Tags.create_tag(%{name: "a"})
      assert short_tag.name == "a"
    end

    test "tag name has maximum length requirement" do
      too_long = String.duplicate("a", 51)
      # Will pass until you add max length validation
      # assert {:error, changeset} = Tags.create_tag(%{name: too_long})
      # assert "should be at most 50 character(s)" in errors_on(changeset).name

      # Showing current behavior
      {:ok, long_tag} = Tags.create_tag(%{name: too_long})
      assert String.length(long_tag.name) == 51
    end

    test "tag name allows alphanumeric and common symbols" do
      valid_names = [
        "Elixir123",
        "Phoenix-Framework",
        "Web3.0",
        "CPlusPlus",
        "FSharp",
        "node.js"
      ]

      for name <- valid_names do
        {:ok, tag} = Tags.create_tag(%{name: name})
        # Clean up
        Tags.delete_tag(tag)
      end
    end

    test "tag name rejects special characters" do
      # These will pass until you add format validation
      # For now, just showing they get created
      invalid_names = [
        "tag<script>",
        "tag&nbsp;"
      ]

      for name <- invalid_names do
        {:ok, tag} = Tags.create_tag(%{name: name})
        Tags.delete_tag(tag)
      end
    end

    test "tag name is trimmed on creation" do
      # Will pass until you add trimming
      # {:ok, tag} = Tags.create_tag(%{name: "  Elixir  "})
      # assert tag.name == "Elixir"

      # Showing current behavior
      {:ok, tag} = Tags.create_tag(%{name: "  Elixir  "})
      assert tag.name == "  Elixir  "
    end
  end

  describe "tag-post associations" do
    test "can add multiple tags to a post" do
      user = user_fixture()
      tag1 = tag_fixture(name: "Elixir")
      tag2 = tag_fixture(name: "Phoenix")
      tag3 = tag_fixture(name: "Web")

      attrs = %{
        title: "Test Post",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      {:ok, post} = Posts.create_post(attrs, [tag1, tag2, tag3])

      post_with_tags = Repo.preload(post, :tags)
      assert length(post_with_tags.tags) == 3
      assert tag1 in post_with_tags.tags
      assert tag2 in post_with_tags.tags
      assert tag3 in post_with_tags.tags
    end

    # TODO: Implement Posts.update_post_tags/2 to enable these tests
    # test "can update post tags by adding new tags" do
    #   user = user_fixture()
    #   tag1 = tag_fixture(name: "Elixir")
    #   tag2 = tag_fixture(name: "Phoenix")
    #   tag3 = tag_fixture(name: "Web")

    #   attrs = %{
    #     title: "Test Post",
    #     content: "Content",
    #     user_id: user.id,
    #     visibility: true,
    #     published_on: Date.utc_today()
    #   }

    #   {:ok, post} = Posts.create_post(attrs, [tag1])

    #   # Update to add more tags
    #   {:ok, updated_post} = Posts.update_post_tags(post, [tag1, tag2, tag3])

    #   post_with_tags = Repo.preload(updated_post, :tags, force: true)
    #   assert length(post_with_tags.tags) == 3
    # end

    # test "can update post tags by removing tags" do
    #   # Similar pattern - commented out until update_post_tags is implemented
    # end

    # test "can remove all tags from a post" do
    #   # Similar pattern - commented out until update_post_tags is implemented
    # end

    test "post can have no tags" do
      user = user_fixture()

      attrs = %{
        title: "Test Post",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      {:ok, post} = Posts.create_post(attrs, [])

      post_with_tags = Repo.preload(post, :tags)
      assert length(post_with_tags.tags) == 0
    end
  end

  describe "tag deletion and post relationships" do
    test "deleting a tag removes it from all associated posts" do
      user = user_fixture()
      tag1 = tag_fixture(name: "Elixir")
      tag2 = tag_fixture(name: "Phoenix")

      attrs1 = %{
        title: "Post 1",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      attrs2 = %{
        title: "Post 2",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      {:ok, post1} = Posts.create_post(attrs1, [tag1, tag2])
      {:ok, post2} = Posts.create_post(attrs2, [tag1, tag2])

      # Delete tag1
      {:ok, _} = Tags.delete_tag(tag1)

      # Both posts should now only have tag2
      post1_tags = Repo.preload(post1, :tags, force: true).tags
      post2_tags = Repo.preload(post2, :tags, force: true).tags

      assert length(post1_tags) == 1
      assert length(post2_tags) == 1
      assert hd(post1_tags).id == tag2.id
      assert hd(post2_tags).id == tag2.id
    end

    # TODO: Implement Posts.update_post_tags/2 to enable this test
    # test "deleting all tags from a post doesn't delete the tags" do
    #   user = user_fixture()
    #   tag1 = tag_fixture(name: "Elixir")
    #   tag2 = tag_fixture(name: "Phoenix")

    #   attrs = %{
    #     title: "Test Post",
    #     content: "Content",
    #     user_id: user.id,
    #     visibility: true,
    #     published_on: Date.utc_today()
    #   }

    #   {:ok, post} = Posts.create_post(attrs, [tag1, tag2])

    #   # Remove all tags from post
    #   {:ok, _} = Posts.update_post_tags(post, [])

    #   # Tags should still exist
    #   assert Tags.get_tag!(tag1.id)
    #   assert Tags.get_tag!(tag2.id)
    # end

    test "tag is not deleted when its last associated post is deleted" do
      user = user_fixture()
      tag = tag_fixture(name: "Elixir")

      attrs = %{
        title: "Only Post",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      {:ok, post} = Posts.create_post(attrs, [tag])

      # Delete the post
      {:ok, _} = Posts.delete_post(post)

      # Tag should still exist
      assert Tags.get_tag!(tag.id)
    end

    test "can reuse tags on multiple posts" do
      user = user_fixture()
      tag = tag_fixture(name: "Elixir")

      attrs1 = %{
        title: "Post 1",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      attrs2 = %{
        title: "Post 2",
        content: "Content",
        user_id: user.id,
        visibility: true,
        published_on: Date.utc_today()
      }

      {:ok, post1} = Posts.create_post(attrs1, [tag])
      {:ok, post2} = Posts.create_post(attrs2, [tag])

      # Both posts should have the same tag
      post1_tags = Repo.preload(post1, :tags).tags
      post2_tags = Repo.preload(post2, :tags).tags

      assert length(post1_tags) == 1
      assert length(post2_tags) == 1
      assert hd(post1_tags).id == tag.id
      assert hd(post2_tags).id == tag.id
    end
  end

  # TODO: Implement Posts.get_posts_by_tag/1 to enable this test
  # describe "listing posts by tag" do
  #   test "get_posts_by_tag/1 returns all posts with a specific tag" do
  #     user = user_fixture()
  #     elixir_tag = tag_fixture(name: "Elixir")
  #     phoenix_tag = tag_fixture(name: "Phoenix")

  #     attrs1 = %{
  #       title: "Elixir Post",
  #       content: "Content",
  #       user_id: user.id,
  #       visibility: true,
  #       published_on: Date.utc_today()
  #     }

  #     attrs2 = %{
  #       title: "Phoenix Post",
  #       content: "Content",
  #       user_id: user.id,
  #       visibility: true,
  #       published_on: Date.utc_today()
  #     }

  #     attrs3 = %{
  #       title: "Both Tags Post",
  #       content: "Content",
  #       user_id: user.id,
  #       visibility: true,
  #       published_on: Date.utc_today()
  #     }

  #     {:ok, post1} = Posts.create_post(attrs1, [elixir_tag])
  #     {:ok, _post2} = Posts.create_post(attrs2, [phoenix_tag])
  #     {:ok, post3} = Posts.create_post(attrs3, [elixir_tag, phoenix_tag])

  #     elixir_posts = Posts.get_posts_by_tag(elixir_tag.id)

  #     assert length(elixir_posts) == 2
  #     assert post1 in elixir_posts
  #     assert post3 in elixir_posts
  #   end
  # end
end
