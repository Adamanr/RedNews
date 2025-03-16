defmodule RednewsWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use RednewsWeb, :html
  use Gettext, backend: RednewsWeb.Gettext

  embed_templates "page_html/*"
end
