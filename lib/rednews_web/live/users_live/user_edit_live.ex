defmodule RednewsWeb.UserEditLive do
  use RednewsWeb, :live_view

  alias Rednews.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="min-h-screen pb-20 bg-gradient-to-br from-indigo-50 via-white to-cyan-50 dark:from-gray-900 dark:via-gray-800 dark:to-indigo-900/50 py-10 px-4 sm:px-6 lg:px-8"
      phx-mounted={
        JS.dispatch("phx:update_avatar",
          detail: %{url: @current_user.avatar || "/images/default-avatar.png"}
        )
      }
    >
      <div class="max-w-3xl mx-auto">
        <div class="text-center mb-12">
          <h1 class="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 to-cyan-500 dark:from-indigo-400 dark:to-cyan-300">
            {gettext("Edit Your Profile")}
          </h1>
          <p class="mt-3 text-lg text-gray-600 dark:text-gray-300">
            {gettext("Customize your personal information and security settings")}
          </p>
        </div>

        <div class="flex justify-center mb-10">
          <label for="avatar-upload" class="cursor-pointer relative group">
            <img
              src={@current_user.avatar || "/images/default-avatar.png"}
              class="w-32 h-32 rounded-full border-4 border-white dark:border-gray-800 shadow-xl object-cover transition-opacity duration-300"
              id="avatar-preview"
              phx-hook="AvatarPreview"
              style="opacity: 1;"
            />
            <div class="absolute inset-0 bg-black/30 rounded-full opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
              <span class="text-white text-sm font-medium">{gettext("Change")}</span>
            </div>
          </label>
        </div>

        <div class="space-y-8">
          <div class="bg-white dark:bg-gray-800/90 rounded-2xl shadow-xl overflow-hidden backdrop-blur-sm">
            <div class="p-6 border-b border-gray-200 dark:border-gray-700">
              <h2 class="text-xl font-bold flex items-center space-x-2 text-gray-800 dark:text-gray-200">
                <svg
                  class="h-6 w-6 text-indigo-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                  />
                </svg>
                <span>{gettext("Personal Information")}</span>
              </h2>
            </div>
            <div class="p-6">
              <.simple_form
                for={@user_info_form}
                id="user_info_form"
                phx-submit="update_user_info"
                class="space-y-5"
              >
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                  <.input
                    field={@user_info_form[:avatar]}
                    type="text"
                    label={gettext("Profile Image URL")}
                    class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                    phx-keyup="update_avatar_preview"
                    phx-debounce="300"
                    placeholder="https://example.com/avatar.jpg"
                  />
                  <div class="flex items-end">
                    <button
                      type="button"
                      phx-click="random_avatar"
                      phx-target="#user_info_form"
                      phx-disable-with={gettext("Saving...")}
                      class="flex items-center w-full space-x-1 px-4 py-3 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg text-gray-700 dark:text-gray-300 transition-colors"
                    >
                      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                        />
                      </svg>
                      <span class="text-sm">{gettext("Random Avatar")}</span>
                    </button>
                  </div>
                </div>

                <.input
                  field={@user_info_form[:username]}
                  type="text"
                  label={gettext("Username")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <.input
                  field={@user_info_form[:login]}
                  type="text"
                  label={gettext("Login")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <.input
                  field={@user_info_form[:desc]}
                  type="textarea"
                  label={gettext("Bio")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200 min-h-[100px]"
                  placeholder={gettext("Tell us about yourself...")}
                />

                <div class="pt-4">
                  <.button
                    class="w-full flex justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white bg-gradient-to-r from-indigo-600 to-cyan-500 hover:from-indigo-700 hover:to-cyan-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 transform hover:scale-[1.02]"
                    phx-disable-with={gettext("Saving...")}
                  >
                    {gettext("Update Profile")}
                    <svg
                      class="ml-2 -mr-1 w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                  </.button>
                </div>
              </.simple_form>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800/90 rounded-2xl shadow-xl overflow-hidden backdrop-blur-sm">
            <div class="p-6 border-b border-gray-200 dark:border-gray-700">
              <h2 class="text-xl font-bold flex items-center space-x-2 text-gray-800 dark:text-gray-200">
                <svg
                  class="h-6 w-6 text-indigo-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
                <span>{gettext("Email Address")}</span>
              </h2>
            </div>
            <div class="p-6">
              <.simple_form
                for={@email_form}
                id="email_form"
                phx-submit="update_email"
                phx-change="validate_email"
                class="space-y-5"
              >
                <.input
                  field={@email_form[:email]}
                  type="email"
                  label={gettext("New Email")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <.input
                  field={@email_form[:current_password]}
                  name="current_password"
                  id="current_password_for_email"
                  type="password"
                  label={gettext("Current Password")}
                  value={@email_form_current_password}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <div class="pt-4">
                  <.button
                    class="w-full flex justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white bg-gradient-to-r from-indigo-600 to-cyan-500 hover:from-indigo-700 hover:to-cyan-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 transform hover:scale-[1.02]"
                    phx-disable-with={gettext("Updating...")}
                  >
                    {gettext("Change Email")}
                    <svg
                      class="ml-2 -mr-1 w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                      />
                    </svg>
                  </.button>
                </div>
              </.simple_form>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800/90 rounded-2xl shadow-xl overflow-hidden backdrop-blur-sm">
            <div class="p-6 border-b border-gray-200 dark:border-gray-700">
              <h2 class="text-xl font-bold flex items-center space-x-2 text-gray-800 dark:text-gray-200">
                <svg
                  class="h-6 w-6 text-indigo-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                  />
                </svg>
                <span>{gettext("Password")}</span>
              </h2>
            </div>
            <div class="p-6">
              <.simple_form
                for={@password_form}
                id="password_form"
                action={~p"/users/log_in?_action=password_updated"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
                class="space-y-5"
              >
                <input
                  name={@password_form[:email].name}
                  type="hidden"
                  id="hidden_user_email"
                  value={@current_email}
                />

                <.input
                  field={@password_form[:password]}
                  type="password"
                  label={gettext("New Password")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label={gettext("Confirm New Password")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                />

                <.input
                  field={@password_form[:current_password]}
                  name="current_password"
                  type="password"
                  label={gettext("Current Password")}
                  id="current_password_for_password"
                  value={@current_password}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700/50 shadow-sm focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 px-4 py-2 transition duration-200"
                  required
                />

                <div class="pt-4">
                  <.button
                    class="w-full flex justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white bg-gradient-to-r from-indigo-600 to-cyan-500 hover:from-indigo-700 hover:to-cyan-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 transform hover:scale-[1.02]"
                    phx-disable-with={gettext("Updating...")}
                  >
                    {gettext("Change Password")}
                    <svg
                      class="ml-2 -mr-1 w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"
                      />
                    </svg>
                  </.button>
                </div>
              </.simple_form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    handle_email_token(token, socket)
  end

  def mount(_params, _session, socket) do
    initialize_forms(socket)
  end

  @impl true
  def handle_event("update_avatar_preview", params, socket) do
    avatar_url = get_avatar_url(params)
    {:noreply, push_avatar_update(socket, avatar_url)}
  end

  def handle_event("random_avatar", _, socket) do
    random_avatar_url = generate_random_avatar_url()
    {:noreply, update_avatar(socket, random_avatar_url)}
  end

  def handle_event("update_user_info", %{"user" => params}, socket) do
    handle_user_info_update(socket, params)
  end

  def handle_event("update_email", %{"current_password" => password, "user" => params}, socket) do
    handle_email_update(socket, password, params)
  end

  def handle_event("update_password", %{"current_password" => password, "user" => params}, socket) do
    handle_password_update(socket, password, params)
  end

  def handle_event("validate_email", %{"current_password" => password, "user" => params}, socket) do
    validate_email(socket, password, params)
  end

  def handle_event(
        "validate_password",
        %{"current_password" => password, "user" => params},
        socket
      ) do
    validate_password(socket, password, params)
  end

  @impl true
  def handle_info({:update_form_with_avatar, avatar_url}, socket) do
    {:noreply, update_form_with_avatar(socket, avatar_url)}
  end

  defp handle_email_token(token, socket) do
    case Accounts.update_user_email(socket.assigns.current_user, token) do
      :ok ->
        {:ok,
         put_flash(socket, :info, gettext("Email changed successfully"))
         |> push_navigate(to: ~p"/users/edit")}

      :error ->
        {:ok,
         put_flash(socket, :error, "Email change link is invalid or it has expired.")
         |> push_navigate(to: ~p"/users/edit")}
    end
  end

  defp initialize_forms(socket) do
    user = socket.assigns.current_user

    socket
    |> assign(
      current_password: nil,
      email_form_current_password: nil,
      current_email: user.email,
      trigger_submit: false
    )
    |> assign_forms(user)
    |> then(&{:ok, &1})
  end

  defp assign_forms(socket, user) do
    socket
    |> assign(:email_form, to_form(Accounts.change_user_email(user)))
    |> assign(:password_form, to_form(Accounts.change_user_password(user)))
    |> assign(:user_info_form, to_form(Accounts.change_user_info(user)))
  end

  defp get_avatar_url(%{"user" => %{"avatar" => url}}), do: url
  defp get_avatar_url(%{"value" => url}), do: url
  defp get_avatar_url(_), do: nil

  defp push_avatar_update(socket, url) do
    push_event(socket, "update_avatar", %{url: url || default_avatar_url()})
  end

  defp update_avatar(socket, url) do
    socket
    |> update_user_info_form(url)
    |> push_avatar_update(url)
  end

  defp update_user_info_form(socket, url) do
    params = Map.put(socket.assigns.user_info_form.params || %{}, "avatar", url)

    changeset =
      socket.assigns.current_user
      |> Accounts.change_user_info(params)
      |> Map.put(:action, :validate)

    assign(socket, user_info_form: to_form(changeset))
  end

  defp handle_user_info_update(socket, params) do
    user = socket.assigns.current_user
    params = ensure_avatar_present(params, user.avatar)
    changeset = Accounts.change_user_info(user, params)

    if changeset.valid? do
      case Accounts.update_user_info(user, params) do
        {:ok, updated_user} ->
          socket
          |> put_flash(:info, gettext("Data has been successfully saved!"))
          |> assign(current_user: updated_user)
          |> assign_forms(updated_user)
          |> then(&{:noreply, &1})

        {:error, changeset} ->
          {:noreply, assign(socket, user_info_form: to_form(changeset))}
      end
    else
      {:noreply, assign(socket, user_info_form: to_form(changeset))}
    end
  end

  defp ensure_avatar_present(params, current_avatar) do
    Map.put_new(params, "avatar", current_avatar)
  end

  defp handle_email_update(socket, password, params) do
    case Accounts.apply_user_email(socket.assigns.current_user, password, params) do
      {:ok, applied_user} ->
        send_email_confirmation(applied_user, socket.assigns.current_user.email)

        {:noreply,
         socket
         |> put_flash(:info, email_update_success_message())
         |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  defp email_update_success_message do
    "A link to confirm your email change has been sent to the new address."
  end

  defp send_email_confirmation(user, email) do
    Accounts.deliver_user_update_email_instructions(
      user,
      email,
      &url(~p"/users/edit/confirm_email/#{&1}")
    )
  end

  defp handle_password_update(socket, password, params) do
    case Accounts.update_user_password(socket.assigns.current_user, password, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign(:password_form, to_form(Accounts.change_user_password(user, params)))}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  defp validate_email(socket, password, params) do
    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  defp validate_password(socket, password, params) do
    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  defp update_form_with_avatar(socket, url) do
    params = Map.put(socket.assigns.user_info_form.params || %{}, "avatar", url)

    changeset =
      socket.assigns.current_user
      |> Accounts.change_user_info(params)
      |> Map.put(:action, :validate)

    assign(socket, user_info_form: to_form(changeset))
  end

  defp generate_random_avatar_url do
    styles = ["adventurer", "avataaars", "bottts", "fun-emoji", "micah"]
    style = Enum.random(styles)
    seed = :crypto.strong_rand_bytes(8) |> Base.encode16()
    "https://api.dicebear.com/7.x/#{style}/svg?seed=#{seed}"
  end

  defp default_avatar_url, do: "/images/default-avatar.png"
end
