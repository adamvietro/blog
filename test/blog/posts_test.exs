defmodule Blog.PostsTest do
  use Blog.DataCase

  describe "posts" do
    alias Blog.Posts.Post
    alias Blog.Posts, as: Posts
    alias Blog.Posts.CoverImage

    import Blog.PostsFixtures
    import Blog.AccountsFixtures

    @invalid_attrs %{title: nil, content: nil, published_on: nil, visibility: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id)
        |> Repo.preload([:tags, :cover_image])

      assert Posts.list_posts() == [post]
    end

    test "list_posts/2 with a :page option returns only that page's posts" do
      user = user_fixture()
      all_posts = for i <- 1..15, do: post_fixture(user_id: user.id, title: "Post #{i}")
      all_ids = MapSet.new(all_posts, & &1.id)

      page1 = Posts.list_posts(nil, page: 1, per_page: 10)
      page2 = Posts.list_posts(nil, page: 2, per_page: 10)
      page1_ids = MapSet.new(page1, & &1.id)
      page2_ids = MapSet.new(page2, & &1.id)

      assert length(page1) == 10
      assert length(page2) == 5
      # No overlap between pages...
      assert MapSet.disjoint?(page1_ids, page2_ids)
      # ...and together they account for every post, none missing or duplicated.
      assert MapSet.union(page1_ids, page2_ids) == all_ids
    end

    test "list_posts/2 without a :page option returns everything, unpaginated" do
      user = user_fixture()
      for i <- 1..15, do: post_fixture(user_id: user.id, title: "Post #{i}")

      assert length(Posts.list_posts()) == 15
    end

    test "count_posts/1 counts what list_posts/2 would return, ignoring pagination" do
      user = user_fixture()
      for i <- 1..3, do: post_fixture(user_id: user.id, title: "Post #{i}", visibility: true)
      post_fixture(user_id: user.id, title: "A draft", visibility: false)

      assert Posts.count_posts(nil) == 3
      assert Posts.count_posts(user) == 3
      assert Posts.count_posts(admin_fixture()) == 4
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id)
        |> Repo.preload([:tags])

      assert Posts.get_post!(post.id) |> Repo.preload([:tags]) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{
        title: "some title",
        content: "some content",
        published_on: ~D[2025-02-15],
        visibility: true,
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.content == "some content"
      assert post.published_on == ~D[2025-02-15]
      assert post.visibility == true
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      update_attrs = %{
        title: "some updated title",
        content: "some updated content",
        published_on: ~D[2025-02-16],
        visibility: false
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.content == "some updated content"
      assert post.published_on == ~D[2025-02-16]
      assert post.visibility == false
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id)
        |> Repo.preload([:tags])

      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id) |> Repo.preload([:tags])
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "create_post/1 post titles must be unique" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert {:error, %Ecto.Changeset{}} =
               Posts.create_post(%{content: "some content", title: post.title})
    end

    test "create_post/1 allows a published_on date in the future, for scheduling" do
      user = user_fixture()
      future_date = Date.add(Date.utc_today(), 7)

      attrs = %{
        title: "A scheduled post",
        content: "some content",
        published_on: future_date,
        visibility: true,
        user_id: user.id
      }

      assert {:ok, %Post{published_on: ^future_date}} = Posts.create_post(attrs)
    end

    test "create_post/1 accepts today's date for published_on" do
      user = user_fixture()

      attrs = %{
        title: "A post published today",
        content: "some content",
        published_on: Date.utc_today(),
        visibility: true,
        user_id: user.id
      }

      assert {:ok, %Post{}} = Posts.create_post(attrs)
    end

    test "create_post/1 with image" do
      valid_attrs = %{
        content: "some content",
        title: "some title",
        cover_image: %{
          url: "https://www.example.com/image.png"
        },
        visible: true,
        published_on: DateTime.utc_now(),
        user_id: user_fixture().id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)

      assert %CoverImage{url: "https://www.example.com/image.png"} =
               Repo.preload(post, :cover_image).cover_image
    end

    test "update_post/1 add an image" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert {:ok, %Post{} = post} =
               Posts.update_post(post, %{
                 cover_image: %{url: "https://www.example.com/image2.png"}
               })

      assert post.cover_image.url == "https://www.example.com/image2.png"
    end
  end
end
