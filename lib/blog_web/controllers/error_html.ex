defmodule BlogWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use BlogWeb, :html

  embed_templates "error_html/*"

  # Falls back to a plain text page for any status without its own template.
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
