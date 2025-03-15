defmodule RednewsWeb.PageController do
  use RednewsWeb, :controller

  alias Rednews.Posts
  alias Rednews.Accounts

  def home(conn, _params) do
    redirect(conn, to: ~p"/news")
  end
end
