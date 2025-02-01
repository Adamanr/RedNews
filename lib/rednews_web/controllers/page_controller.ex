defmodule RednewsWeb.PageController do
  use RednewsWeb, :controller

  alias Rednews.Posts
  alias Rednews.Accounts

  @doc """
  Renders the home page

  ## Parameters
  - `conn`: The connection object.
  - `_params`: Unused parameters.

  ## Returns
  - Renders the home page with the latest headlines, articles, channels, tags, and categories.
  """
  def home(conn, _params) do
    render(conn, :home,
      layout: false,
      latest_headline: Posts.get_latest_headline(),
      headlines: Posts.list_headlines(),
      articles: Posts.list_article(),
      channels: Accounts.list_channel(),
      popular_tags: Posts.get_popular_tags(),
      popular_categories: Posts.get_popular_categories()
    )
  end
end
