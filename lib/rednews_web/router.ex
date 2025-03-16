defmodule RednewsWeb.Router do
  use RednewsWeb, :router

  import RednewsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RednewsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :set_locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RednewsWeb do
    pipe_through :browser

    get "/change_locale/:locale", LocaleController, :change_locale
    get "/", PageController, :home
  end

  defp set_locale(conn, _opts) do
    locale =
      conn.assigns[:locale] ||
        get_session(conn, :locale) ||
        Application.get_env(:rednews, RednewsWeb.Gettext)[:default_locale]

    Gettext.put_locale(RednewsWeb.Gettext, locale)

    conn |> assign(:locale, locale)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RednewsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:rednews, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RednewsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Articles routes

  scope "/", RednewsWeb do
    pipe_through :browser

    live "/", ArticlesLive.Index, :index

    live "/articles", ArticlesLive.Index, :index
    live "/articles/category/:category", ArticlesLive.Index, :index
    live "/articles/article/:id", ArticlesLive.Show, :show

    live "/channels", ChannelsLive.Index, :index
    live "/channels/channel/:id", ChannelsLive.Show, :show

    live "/news", HeadlinesLive.Index, :index
    live "/news/headline/:id", HeadlinesLive.Show, :show
  end

  scope "/", RednewsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin,
      on_mount: [{RednewsWeb.UserAuth, :ensure_authenticated}] do
      live "/articles/new", ArticlesLive.Index, :new
      live "/articles/article/:id/edit", ArticlesLive.Index, :edit
      live "/articles/article/:id/show/edit", ArticlesLive.Show, :edit

      live "/channels/new", ChannelsLive.Index, :new
      live "/channels/channel/:id/edit", ChannelsLive.Index, :edit
      live "/channels/channel/:id/show/edit", ChannelsLive.Show, :edit

      live "/news/new", HeadlinesLive.Index, :new
      live "/news/headline/:id/edit", HeadlinesLive.Index, :edit
      live "/news/headline/:id/show/edit", HeadlinesLive.Show, :edit
    end
  end

  ## Authentication routes

  scope "/", RednewsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{RednewsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", RednewsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{RednewsWeb.UserAuth, :ensure_authenticated}] do
      live "/users/user/:id", UsersLive.UserProfile, :new
      live "/users/edit", UserEditLive, :edit
      live "/users/edit/confirm_email/:token", UserEditLive, :confirm_email
    end
  end

  scope "/", RednewsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{RednewsWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
