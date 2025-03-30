defmodule RednewsWeb.UserRegistrationLive do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen dark:bg-gradient-to-br dark:from-gray-900 dark:via-blue-900 dark:to-purple-900  bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff] flex items-center justify-center p-6">
      <div class="w-full max-w-7xl grid grid-cols-1 lg:grid-cols-2 bg-white shadow-2xl rounded-3xl overflow-hidden animate-fade-in">
        <div class="p-10 bg-white dark:bg-gray-900 h-full flex flex-col justify-center space-y-6">
          <div class="text-center mb-8">
            <h1 class="text-4xl font-black bg-clip-text text-transparent bg-gradient-to-r from-[#6a11cb] to-[#2575fc] mb-4">
              {gettext("Join the Community")}
            </h1>
            <p class="text-sm dark:text-gray-400 text-gray-600">
              {gettext("Create your unique account")}
            </p>
          </div>

          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
            class="space-y-4"
          >
            <.error :if={@check_errors}>
              <div
                class="bg-red-50 border border-red-300 text-red-700 px-4 py-3 rounded relative"
                role="alert"
              >
                <span class="block sm:inline">
                  {gettext("Oops, something went wrong! Check the errors below")}
                </span>
              </div>
            </.error>

            <div class="md:grid md:space-y-0 space-y-6 grid-cols-2 gap-4">
              <.input
                field={@form[:login]}
                type="text"
                label={gettext("Username")}
                required
                class="focus:ring-[#6a11cb] focus:border-[#6a11cb]"
              />
              <.input
                field={@form[:username]}
                type="text"
                label={gettext("Display Name")}
                required
                class="focus:ring-[#2575fc] focus:border-[#2575fc]"
              />
            </div>

            <.input
              field={@form[:email]}
              type="email"
              label={gettext("Email Address")}
              required
              class="focus:ring-[#00d4ff] focus:border-[#00d4ff]"
            />

            <.input
              field={@form[:password]}
              type="password"
              label={gettext("Create Password")}
              required
              class="focus:ring-[#6a11cb] focus:border-[#6a11cb]"
            />

            <.input
              field={@form[:avatar]}
              type="text"
              label={gettext("Profile Picture URL")}
              placeholder={gettext("Paste your avatar link")}
              class="focus:ring-[#2575fc] focus:border-[#2575fc]"
            />

            <div class="pt-4">
              <.button
                phx-disable-with={gettext("Creating your profile...")}
                class="w-full py-3 rounded-full text-white font-bold
                       bg-gradient-to-r from-[#6a11cb] to-[#2575fc]
                       hover:from-[#2575fc] hover:to-[#6a11cb]
                       transition-all duration-300
                       transform hover:scale-105
                       focus:outline-none focus:ring-4 focus:ring-[#00d4ff]/50"
              >
                {gettext("Create Your Account")}
              </.button>
            </div>
          </.simple_form>

          <div class="text-center text-sm dark:text-gray-300 text-gray-600 mt-4">
            {gettext("Already have an account?")}
            <.link
              navigate={~p"/users/log_in"}
              class="ml-2 font-semibold text-[#6a11cb] hover:underline"
            >
              {gettext("Log In")}
            </.link>
          </div>
        </div>

        <div class="hidden lg:block relative overflow-hidden dark:bg-gradient-to-br dark:from-gray-800 dark:via-gray-900 dark:to-indigo-800 bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff]">
          <div class="absolute inset-0 bg-pattern opacity-20"></div>
          <div class="relative z-10 flex items-center justify-center h-full p-10 text-white text-center">
            <div class="space-y-6">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 200 200"
                class="mx-auto w-64 h-64 animate-pulse"
              >
                <circle cx="100" cy="100" r="90" fill="rgba(255,255,255,0.1)" />
                <circle cx="100" cy="100" r="70" fill="rgba(255,255,255,0.2)" />
                <path d="M100 40 L130 100 L70 100 Z" fill="white" transform="rotate(45 100 100)" />
                <circle cx="100" cy="100" r="20" fill="white" />
              </svg>
              <h2 class="text-3xl font-bold">
                {gettext("Welcome to RedNews")}
              </h2>
              <p class="text-sm opacity-80">
                {gettext("One step closer to connecting with the world")}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
