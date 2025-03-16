defmodule RednewsWeb.LiveHooks do
  import Phoenix.Component

  def on_mount(:set_locale, _params, session, socket) do
    locale =
      session["locale"] || Application.get_env(:rednews, RednewsWeb.Gettext)[:default_locale]

    Gettext.put_locale(RednewsWeb.Gettext, locale)

    {:cont, socket |> assign(:locale, locale)}
  end
end
