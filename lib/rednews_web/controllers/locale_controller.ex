defmodule RednewsWeb.LocaleController do
  use RednewsWeb, :controller

  @doc """
  Changes the locale of the current user session.
  """
  def change_locale(conn, %{"locale" => locale}) do
    supported_locales = Application.get_env(:rednews, RednewsWeb.Gettext)[:locales]

    if locale in supported_locales do
      Phoenix.PubSub.broadcast(Rednews.PubSub, "locale", {:locale_changed, locale})

      conn
      |> put_session(:locale, locale)
      |> configure_session(renew: true)
      |> redirect(to: redirect_back_or_default(conn))
    else
      conn
      |> put_flash(:error, "Unsupported locale")
      |> redirect(to: redirect_back_or_default(conn))
    end
  end

  defp redirect_back_or_default(conn) do
    case get_req_header(conn, "referer") do
      [referer | _] ->
        uri = URI.parse(referer)
        uri.path <> if uri.query, do: "?#{uri.query}", else: ""
    end
  end
end
