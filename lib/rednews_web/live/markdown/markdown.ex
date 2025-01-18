defmodule Rednews.MarkdownHelper do
  @moduledoc """
  Auxiliary module for working with Markdown.
  """

  @doc """
  Converts Markdown to HTML.
  """
  def to_html(markdown) do
    Earmark.as_html!(markdown)
  end
end
