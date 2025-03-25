defmodule RednewsWeb.UserEditLive do
  use RednewsWeb, :live_view

  alias Rednews.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center mt-5">
      {gettext("Editing main data")}
      <:subtitle>{gettext("You can change your basic data right here!")}</:subtitle>
    </.header>

    <div class="space-y-12 h-fit w-1/2 mx-auto">
      <div class="mt-10 border-2 border-black p-4 rounded-md">
        <h1 class="font-bold">{gettext("Editing user info")}</h1>
        <hr class="mt-2 border-black" />
        <.simple_form for={@user_info_form} id="user_info_form" phx-submit="update_user_info">
          <.input
            field={@user_info_form[:avatar]}
            type="text"
            label={gettext("Profile Image")}
            required
          />
          <.input field={@user_info_form[:username]} type="text" label={gettext("Username")} required />
          <.input field={@user_info_form[:login]} type="text" label={gettext("Login")} required />
          <.input
            field={@user_info_form[:desc]}
            type="textarea"
            label={gettext("Description")}
            required
          />

          <:actions>
            <.button class="border-2 border-black" phx-disable-with="Changing...">
              {gettext("Change user info")}
            </.button>
          </:actions>
        </.simple_form>
      </div>
      <hr class="mt-4" />
      <div class="mt-10 border-2 border-black p-4 rounded-md">
        <h1 class="font-bold">{gettext("Editing email")}</h1>
        <hr class="mt-2 border-black" />
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label={gettext("Email")} required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label={gettext("Current password")}
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button class="border-2 border-black" phx-disable-with="Changing...">
              {gettext("Change email")}
            </.button>
          </:actions>
        </.simple_form>
      </div>
      <hr class="mt-4" />
      <div class="mt-10 h-full border-2 border-black p-4 rounded-md">
        <h1 class="font-bold">{gettext("Editing password")}</h1>
        <hr class="mt-2 border-black" />
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
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
            label={gettext("New password")}
            required
          />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label={gettext("Confirm new password")}
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label={gettext("Current password")}
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button class="border-2 border-black" phx-disable-with="Changing...">
              {gettext("Change password")}
            </.button>
          </:actions>
        </.simple_form>
      </div>
      <div class="h-24"></div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/edit")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    user_info_changeset = Accounts.change_user_info(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:user_info_form, to_form(user_info_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/edit/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("update_user_info", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user
    changeset = Accounts.change_user_info(user, user_params)

    if changeset.valid? do
      case Accounts.update_user_info(user, user_params) do
        {:ok, updated_user} ->
          user_info_form =
            updated_user
            |> Accounts.change_user_info(user_params)
            |> to_form()

          socket =
            socket
            |> put_flash(:info, gettext("Data has been successfully saved!"))
            |> assign(user_info_form: user_info_form)

          {:noreply, socket}

        {:error, changeset} ->
          {:noreply, assign(socket, user_info_form: to_form(changeset))}
      end
    else
      {:noreply, assign(socket, user_info_form: to_form(changeset))}
    end
  end
end
