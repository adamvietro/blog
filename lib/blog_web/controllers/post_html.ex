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
end
