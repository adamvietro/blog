defmodule BlogWeb.PostHTML do
  use BlogWeb, :html

  embed_templates "post_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :id, :string
  attr :tags, :list

  def post_form(assigns)

  @doc """
  Render Markdown content safely, including triple-backtick code blocks.

  Usage:
      <.markdown content={@post.content} />
  """
  attr :content, :string, required: true

  def markdown(assigns) do
    html_content =
      assigns.content
      |> Earmark.as_html!()
      |> String.replace(~r/class="elixir"/, "class=\"language-elixir\"")
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :html_content, html_content)

    ~H"""
    <div class="prose text-gray-800">{@html_content}</div>
    """
  end
end
