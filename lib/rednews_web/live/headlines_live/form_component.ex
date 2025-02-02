defmodule RednewsWeb.HeadlinesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias Rednews.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Рассказать о новости
        <:subtitle>Расскажите всем о том, что произошло!</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="headlines-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Заголовок" />
        <.input field={@form[:content]} type="textarea" label="Текст новости" />
        <.input
          field={@form[:category]}
          type="select"
          label="Категория"
          options={Posts.list_categories()}
        />
        <%= if length(Accounts.list_user_channels(1)) == 0 do %>
          <h1 class="text-rose-400 font-bold">
            Для создания новости вам нужен канал!
            <a class="text-sky-600" href="/channels/new"> Создать канал </a>
          </h1>
        <% else %>
          <.input
            field={@form[:author]}
            type="select"
            label="Автор"
            options={Enum.map(Accounts.list_user_channels(assigns.myself.cid), &{&1.name, &1.id})}
          />
        <% end %>

        <.input field={@form[:header]} type="text" label="Картинка новости (URL)" />
        <.input
          field={@form[:tags]}
          type="text"
          label="Тэги (через запятую)"
          value={Enum.join(@headlines.tags || [], ", ")}
          placeholder="Игры, Новости"
        />

        <:actions>
          <.button class="bg-zinc-700" phx-disable-with="Saving...">Опубликовать</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @moduledoc """
  LiveView module for handling headlines updates and validations.
  """

  @impl true
  def update(%{headlines: headlines} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Posts.change_headlines(headlines)) end)}
  end

  @impl true
  def handle_event("validate", %{"headlines" => headlines_params}, socket) do
    changeset = Posts.change_headlines(socket.assigns.headlines, headlines_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"headlines" => headlines_params}, socket) do
    case socket.assigns.action do
      :edit -> save_and_notify(socket, :update, socket.assigns.headlines, headlines_params)
      :new -> save_and_notify(socket, :create, headlines_params)
    end
  end

  defp save_and_notify(socket, action, headlines_or_params, headlines_params \\ nil) do
    save_fn = if action == :update, do: &Posts.update_headlines/2, else: &Posts.create_headlines/1

    args =
      if action == :update,
        do: [headlines_or_params, headlines_params],
        else: [headlines_or_params]

    case apply(save_fn, args) do
      {:ok, headlines} ->
        notify_parent({:saved, headlines})

        {:noreply,
         socket
         |> put_flash(:info, "Headlines #{action}d successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
