defmodule RednewsWeb.UserForgotPasswordLive do
  use RednewsWeb, :live_view

  alias Rednews.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen dark:bg-gradient-to-br dark:from-gray-900 dark:via-blue-900 dark:to-purple-900 bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff] flex items-center justify-center p-6">
      <div class="w-full max-w-4xl bg-white shadow-2xl rounded-3xl overflow-hidden animate-fade-in">
        <div class="grid grid-cols-1 lg:grid-cols-2">
          <div class="hidden lg:block relative overflow-hidden dark:bg-gradient-to-br dark:from-gray-800 dark:via-gray-900 dark:to-indigo-800 bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff]">
            <div class="absolute inset-0 bg-pattern opacity-20"></div>
            <div class="relative z-10 flex items-center justify-center h-full p-10 text-white text-center">
              <div class="space-y-6">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 200 200"
                  class="mx-auto w-48 h-48 animate-float"
                >
                  <path d="M30 100 L100 30 L170 100 L100 170 Z" fill="rgba(255,255,255,0.2)" />
                  <path d="M50 100 L100 50 L150 100 L100 150 Z" fill="rgba(255,255,255,0.4)" />
                  <path d="M70 100 L100 70 L130 100 L100 130 Z" fill="white" opacity="0.8" />
                  <path d="M85 100 L100 85 L115 100 L100 115 Z" fill="white" />
                </svg>
                <h2 class="text-3xl font-bold">
                  {gettext("Reset Password")}
                </h2>
                <p class="text-sm opacity-80">
                  {gettext("We've got your back!")}
                </p>
              </div>
            </div>
          </div>

          <div class="p-10 dark:bg-gray-900 bg-white flex flex-col justify-center space-y-6">
            <div class="text-center mb-8">
              <h1 class="text-4xl h-fit font-black bg-clip-text text-transparent bg-gradient-to-r from-[#6a11cb] to-[#2575fc] mb-4">
                {gettext("Forgot Password?")}
              </h1>
              <p class="text-sm dark:text-gray-400 text-gray-600">
                {gettext("Enter your email and we'll send you reset instructions")}
              </p>
            </div>

            <.simple_form
              for={@form}
              id="reset_password_form"
              phx-submit="send_email"
              class="space-y-5"
            >
              <.input
                field={@form[:email]}
                type="email"
                label={gettext("Email Address")}
                required
                class="focus:ring-2 focus:ring-[#6a11cb] focus:border-[#6a11cb]
                             transition-all duration-300 ease-in-out
                             group-hover:border-[#2575fc]"
              />

              <div class="pt-4">
                <.button
                  phx-disable-with={gettext("Sending...")}
                  class="w-full py-3 rounded-full text-white font-bold
                         bg-gradient-to-r from-[#6a11cb] to-[#2575fc]
                         hover:from-[#2575fc] hover:to-[#6a11cb]
                         transition-all duration-300
                         transform hover:scale-105
                         focus:outline-none focus:ring-4 focus:ring-[#00d4ff]/50
                         shadow-lg hover:shadow-xl"
                >
                  {gettext("Send Reset Instructions")}
                </.button>
              </div>
            </.simple_form>

            <div class="text-center text-sm text-gray-600 mt-4">
              <.link href={~p"/users/log_in"} class="font-semibold text-[#6a11cb] hover:underline">
                {gettext("Back to Login")}
              </.link>
              <span class="mx-2">•</span>
              <.link href={~p"/users/register"} class="font-semibold text-[#2575fc] hover:underline">
                {gettext("Create Account")}
              </.link>
            </div>

            <%= if @email_sent do %>
              <div class="mt-6 p-4 bg-green-50 rounded-lg border border-green-200 animate-fade-in">
                <div class="flex items-center space-x-3">
                  <svg
                    class="w-5 h-5 text-green-500 flex-shrink-0"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    >
                    </path>
                  </svg>
                  <p class="text-sm text-green-800">
                    {gettext("Check your email for reset instructions!")}
                  </p>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(form: to_form(%{}, as: "user"))
     |> assign(:email_sent, false)}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
