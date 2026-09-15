defmodule Blog.TagsTest do
  use Blog.DataCase

  alias Blog.Tags

  describe "tags" do
    alias Blog.Tags.Tag

    import Blog.TagsFixtures

    @invalid_attrs %{name: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Tags.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Tags.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some tag"}

      assert {:ok, %Tag{} = tag} = Tags.create_tag(valid_attrs)
      assert tag.name == "some tag"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(@invalid_attrs)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.id) end
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture(name: "old name")
      assert {:ok, %Tag{} = tag} = Tags.update_tag(tag, %{name: "new name"})
      assert tag.name == "new name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, @invalid_attrs)
      assert tag == Tags.get_tag!(tag.id)
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end
  end

  describe "find_or_create_tags/1" do
    alias Blog.Tags.Tag

    import Blog.TagsFixtures

    test "creates a new tag when none exists with that name" do
      assert [] = Tags.list_tags()

      assert [%Tag{name: "elixir"}] = Tags.find_or_create_tags("elixir")

      assert [%Tag{name: "elixir"}] = Tags.list_tags()
    end

    test "reuses an existing tag instead of creating a duplicate" do
      existing = tag_fixture(name: "elixir")

      assert [tag] = Tags.find_or_create_tags("elixir")

      assert tag.id == existing.id
      assert length(Tags.list_tags()) == 1
    end

    test "splits on commas, creating and reusing tags as needed" do
      tag_fixture(name: "elixir")

      tags = Tags.find_or_create_tags("elixir, phoenix, testing")

      assert Enum.map(tags, & &1.name) == ["elixir", "phoenix", "testing"]
      assert length(Tags.list_tags()) == 3
    end

    test "trims whitespace around each name" do
      assert [%Tag{name: "elixir"}] = Tags.find_or_create_tags("  elixir  ")
    end

    test "drops empty segments from things like trailing commas" do
      assert [%Tag{name: "elixir"}] = Tags.find_or_create_tags("elixir, , ")
    end

    test "de-duplicates repeated names in the same input" do
      assert [%Tag{name: "elixir"}] = Tags.find_or_create_tags("elixir, elixir")
    end

    test "returns an empty list for nil or blank input" do
      assert Tags.find_or_create_tags(nil) == []
      assert Tags.find_or_create_tags("") == []
      assert Tags.find_or_create_tags("   ") == []
    end
  end
end
