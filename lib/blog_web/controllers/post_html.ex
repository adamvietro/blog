defmodule BlogWeb.PostHTML do
  use BlogWeb, :html

  embed_templates "post_html/*"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :id, :string
  attr :tag_names, :string, default: ""
  attr :all_tags, :list, default: []

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
      |> Earmark.as_html!(%Earmark.Options{breaks: true})
      |> String.replace(~r/<code class="([\w-]+)">/, "<code class=\"language-\\1\">")
      |> Phoenix.HTML.raw()

    assigns = assign(assigns, :html_content, html_content)

    ~H"""
    <div class="prose">{@html_content}</div>
    """
  end

  @doc """
  Render a post as a card list item (index / search results)

  Usage:
    <.post_row post={post} current_user={@current_user} />
  """
  attr :post, Blog.Posts.Post, required: true
  attr :current_user, :any

  def post_row(assigns) do
    ~H"""
    <li class="group flex gap-4 py-5 first:pt-0 last:pb-0">
      <%= if @post.cover_image && @post.cover_image.url do %>
        <img
          src={@post.cover_image.url}
          class="h-16 w-16 flex-none rounded-md border border-zinc-800 object-cover sm:h-20 sm:w-20"
        />
      <% end %>
      <div class="min-w-0 flex-1">
        <a
          href={~p"/posts/#{@post.id}"}
          class="text-lg font-semibold text-zinc-100 transition-colors group-hover:text-brand"
        >
          {BlogWeb.PostHTML.preview_title(@post.title, 100)}
        </a>
        <div class="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1.5">
          <span class="font-mono text-xs text-zinc-500">{@post.published_on}</span>
          <div :if={@post.tags != []} class="flex flex-wrap gap-1.5">
            <span
              :for={tag <- @post.tags}
              class="rounded-full bg-zinc-800/80 px-2 py-0.5 text-xs text-zinc-400"
            >
              {tag.name}
            </span>
          </div>
        </div>
      </div>
      <%= if @current_user && @current_user.admin do %>
        <.post_actions post={@post} />
      <% end %>
    </li>
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
    <div class="flex flex-none items-start gap-3 text-sm">
      <a href={~p"/posts/#{@post.id}/edit"} class="text-zinc-500 transition-colors hover:text-brand">
        Edit
      </a>
      <a
        href={~p"/posts/#{@post.id}"}
        method="delete"
        data-confirm="Are you sure?"
        class="text-zinc-500 transition-colors hover:text-red-400"
      >
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
    <button
      id="load-more-btn"
      class="mx-auto mt-8 block rounded-md border border-zinc-700 px-4 py-2 text-sm font-medium text-zinc-300 transition-colors hover:border-brand hover:text-brand"
    >
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
