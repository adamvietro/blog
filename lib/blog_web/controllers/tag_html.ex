defmodule BlogWeb.TagHTML do
  use BlogWeb, :html

  embed_templates "tag_html/*"

  @doc """
  Renders a tag form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def tag_form(assigns)

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

  @doc """
  Render the rows for a table of posts (index)

  Usage:
    <.post_row post={post} current_user={@current_user} />
  """
  attr :post, Blog.Posts.Post, required: true
  attr :current_user, :any

  def post_row(assigns) do
    ~H"""
    <tr>
      <td>
        <a class="title" href={~p"/posts/#{@post.id}"}>
          {BlogWeb.PostHTML.preview_title(@post.title, 25)}
        </a>
      </td>
      <td>
        <a class="content" href={~p"/posts/#{@post.id}"}>
          {BlogWeb.PostHTML.preview_content(@post.content, 60)}
        </a>
      </td>
      <%= if @current_user && @current_user.admin do %>
        <td class="actions">
          <.post_actions post={@post} />
        </td>
      <% end %>
    </tr>
    """
  end

  @doc """
  Render the action buttons for delete and edit.

  Usage:
    <.post_actions post={@post} />
  """
  attr :post, Blog.Posts.Post, required: true

  def post_actions(assigns) do
    ~H"""
    <div class="links">
      <a href={~p"/posts/#{@post.id}/edit"} class="link">Edit</a>
      <a href={~p"/posts/#{@post.id}"} method="delete" data-confirm="Are you sure?" class="link">
        Delete
      </a>
    </div>
    """
  end

  @doc """
  Renders a load more posts button.

  Usage:
    <.load_more_button />
  """
  def load_more_button(assigns) do
    ~H"""
    <button id="load-more-btn" class="mt-4 p-2 bg-blue-500 text-white rounded">
      More Posts
    </button>
    """
  end

  @doc """
  Renders the content within the content column of the post table.

  Usage:
    {BlogWeb.PostHTML.preview_content(@post.content, 50)}
  """
  def preview_content(content, max_chars \\ 50) do
    content = String.trim(content)

    if String.length(content) > max_chars do
      String.slice(content, 0, max_chars) <> "..."
    else
      content
    end
  end

  @doc """
  Renders the title within the title column of the post table.

  Usage:
    {BlogWeb.PostHTML.preview_title(@post.title, 25)}
  """
  def preview_title(title, max_chars \\ 25) do
    title = String.trim(title)

    if String.length(title) > max_chars do
      String.slice(title, 0, max_chars) <> "..."
    else
      title
    end
  end
end
