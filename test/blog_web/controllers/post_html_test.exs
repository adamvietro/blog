defmodule BlogWeb.PostHTMLTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias BlogWeb.PostHTML

  describe "markdown/1" do
    test "tags a fenced code block with its language, even one not built into Prism's core bundle" do
      html = render_component(&PostHTML.markdown/1, content: "```ruby\nputs 1\n```")

      assert html =~ ~s(<code class="language-ruby">)
    end

    test "still works for a language that used to be hardcoded" do
      html = render_component(&PostHTML.markdown/1, content: "```elixir\ndef hi, do: :ok\n```")

      assert html =~ ~s(<code class="language-elixir">)
    end

    test "leaves a fenced block with no language declared alone" do
      html = render_component(&PostHTML.markdown/1, content: "```\nplain text\n```")

      refute html =~ "language-"
      assert html =~ "plain text"
    end

    test "renders ordinary markdown" do
      html = render_component(&PostHTML.markdown/1, content: "# Hello\n\nSome **bold** text.")

      assert html =~ "<h1>"
      assert html =~ "Hello"
      assert html =~ "<strong>bold</strong>"
    end

    test "a single newline renders as a line break, without needing a literal <br/>" do
      html = render_component(&PostHTML.markdown/1, content: "Line one\nLine two")

      assert html =~ "<br"
    end

    test "a blank line still starts a new paragraph, same as before" do
      html = render_component(&PostHTML.markdown/1, content: "First paragraph.\n\nSecond paragraph.")

      assert html =~ ~r{<p>\s*First paragraph\.\s*</p>}
      assert html =~ ~r{<p>\s*Second paragraph\.\s*</p>}
    end
  end

  describe "meta_description/2" do
    test "strips markdown formatting down to plain text" do
      content = "# A Heading\n\nSome **bold** and _italic_ and `inline code`."

      assert PostHTML.meta_description(content) ==
               "A Heading Some bold and italic and inline code."
    end

    test "drops fenced code blocks entirely rather than dumping raw code" do
      content = "Intro text.\n\n```elixir\ndef hi, do: :ok\n```\n\nOutro text."

      description = PostHTML.meta_description(content)

      assert description =~ "Intro text."
      assert description =~ "Outro text."
      refute description =~ "def hi"
    end

    test "keeps a link's visible text and drops the URL" do
      content = "Check out [my project](https://example.com/project) for details."

      assert PostHTML.meta_description(content) ==
               "Check out my project for details."
    end

    test "truncates long content with an ellipsis at the given length" do
      content = String.duplicate("word ", 50) |> String.trim()

      description = PostHTML.meta_description(content, 20)

      assert String.length(description) == 21
      assert String.ends_with?(description, "…")
    end

    test "leaves short content untouched" do
      assert PostHTML.meta_description("Short.", 160) == "Short."
    end
  end

  describe "preview_title/2" do
    test "leaves a short title untouched" do
      assert PostHTML.preview_title("Short title") == "Short title"
    end

    test "truncates a long title with an ellipsis" do
      title = String.duplicate("a", 30)

      assert PostHTML.preview_title(title, 10) == String.duplicate("a", 10) <> "..."
    end
  end

  describe "preview_content/2" do
    test "leaves short content untouched" do
      assert PostHTML.preview_content("Short content") == "Short content"
    end

    test "truncates long content with an ellipsis" do
      content = String.duplicate("a", 100)

      assert PostHTML.preview_content(content, 10) == String.duplicate("a", 10) <> "..."
    end
  end

  describe "post_actions/1" do
    test "renders edit and delete links for the given post" do
      post = %Blog.Posts.Post{id: 42}

      html = render_component(&PostHTML.post_actions/1, post: post)

      assert html =~ ~s(href="/posts/42/edit")
      assert html =~ ~s(href="/posts/42")
      assert html =~ "Edit"
      assert html =~ "Delete"
    end
  end
end
