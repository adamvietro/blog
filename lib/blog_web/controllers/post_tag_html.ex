defmodule BlogWeb.Post_TagHTML do
  use BlogWeb, :html

  embed_templates "post_tag_html/*"

  @doc """
  Renders a post_tag form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def post_tag_form(assigns)
end
