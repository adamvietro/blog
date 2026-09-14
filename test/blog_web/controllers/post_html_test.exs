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
  end
end
