defmodule RednewsWeb.UserRegistrationLive do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="relative flex items-center justify-center min-h-screen bg-[#bdbdbd]">
      <div class="mx-auto max-w-md px-5 bg-opacity-50 py-8 bg-white shadow-md rounded-lg flex-shrink-0">
        <.header class=" mb-6">
          <h1 class="text-3xl font-bold">Регистрация</h1>
          <:subtitle>
            <p class="text-sm text-gray-600 mt-2">
              Уже зарегистрированы?
              <.link
                navigate={~p"/users/log_in"}
                class="font-semibold bg-zinc-600 text-brand hover:underline"
              >
                Войдите
              </.link>
              в свою учетную запись.
            </p>
          </:subtitle>
        </.header>

        <div>
          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
          >
            <.error :if={@check_errors}>
              <div class="text-red-600 text-sm font-medium mb-4">
                Упс, что-то пошло не так! Проверьте ошибки ниже.
              </div>
            </.error>

            <.input field={@form[:email]} type="email" label="Email" required class="mb-4" />
            <.input
              field={@form[:password]}
              type="password"
              label="Пароль"
              required
              class="mb-4"
            />
            <.input
              field={@form[:avatar]}
              type="text"
              label="Ссылка на аватар"
              placeholder="https://example.com/avatar.png"
              class="mb-4"
            />
            <.input field={@form[:login]} type="text" label="Логин" required class="mb-4" />
            <.input
              field={@form[:username]}
              type="text"
              label="Имя пользователя"
              required
              class="mb-4"
            />

            <:actions>
              <.button
                phx-disable-with="Создание учетной записи..."
                class="w-full bg-brand text-white py-2 px-4 rounded hover:bg-brand-dark"
              >
                Создать учетную запись
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>

      <div class="hidden lg:block">
        <img
          src="https://static.wixstatic.com/media/7ac599_7bd42534546f42ba9c9eec6de6b837f5~mv2.jpg/v1/fill/w_710,h_710,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/7ac599_7bd42534546f42ba9c9eec6de6b837f5~mv2.jpg"
          alt="Registration Illustration"
          class="max-w-full h-screen "
        />
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
