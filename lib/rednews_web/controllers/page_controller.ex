defmodule RednewsWeb.PageController do
  use RednewsWeb, :controller
  use Gettext, backend: RednewsWeb.Gettext

  def set(conn, %{"locale" => locale, "return_to" => return_to}) do
    conn
    |> put_session(:locale, locale)
    |> redirect(to: return_to)
  end

  def home(conn, _params) do
    redirect(conn, to: ~p"/news")
  end
end
