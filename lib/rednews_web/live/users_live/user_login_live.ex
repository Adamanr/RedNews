defmodule RednewsWeb.UserLoginLive do
  use RednewsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="relative flex items-center justify-center min-h-screen bg-[#72adf0]">
      <div class="hidden lg:block">
        <img
          src="https://static.wixstatic.com/media/7ac599_da9f082770c1433591cce89a9ceeaf36~mv2.jpg/v1/fill/w_710,h_710,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/7ac599_da9f082770c1433591cce89a9ceeaf36~mv2.jpg"
          alt="Registration Illustration"
          class="max-w-full p-20 h-screen "
        />
      </div>

      <div class="w-[25vw] mx-auto max-w-md px-5 bg-opacity-50 py-8 bg-white shadow-md rounded-lg flex-shrink-0">
        <.header class=" mb-6">
          <h1 class="text-3xl font-bold">{gettext("Authorization")}</h1>
          <:subtitle>
            <p class="text-sm text-gray-600 mt-2">
              {gettext("Not registered yet?")}
              <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
                {gettext("Register")}
              </.link>
            </p>
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label={gettext("Email")} required />
          <.input field={@form[:password]} type="password" label={gettext("Password")} required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label={gettext("Remember me")} />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              {gettext("Forgot password?")}
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="text-white font-bold bg-zinc-600 w-full">
              {gettext("Login")}
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
