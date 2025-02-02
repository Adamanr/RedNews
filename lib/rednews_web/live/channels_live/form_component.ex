defmodule RednewsWeb.ChannelsLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Accounts
  alias Rednews.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Создание канала
        <:subtitle>Создайте канал для публикации новостей</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="channels-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Название" />
        <.input field={@form[:desc]} type="text" label="Описание" />
        <.input field={@form[:logo]} type="text" label="Логотип (URL)" />
        <.input field={@form[:header]} type="text" label="Фон (URL)" />
        <.input
          field={@form[:category]}
          type="select"
          label="Категория"
          options={Posts.list_categories()}
        />
        <.input field={@form[:links]} type="text" label="Ссылка на сайт канала" />
        <:actions>
          <.button class="bg-zinc-600" phx-disable-with="Saving...">Сохранить</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{channels: channels} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_channels(channels))
     end)}
  end

  @impl true
  def handle_event("validate", %{"channels" => channels_params}, socket) do
    changeset = Accounts.change_channels(socket.assigns.channels, channels_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"channels" => channels_params}, socket) do
    save_channels(socket, socket.assigns.action, channels_params)
  end

  defp save_channels(socket, :edit, channels_params) do
    channels_params = Map.put(channels_params, "author", socket.assigns.myself.cid)

    case Accounts.update_channels(socket.assigns.channels, channels_params) do
      {:ok, channels} ->
        notify_parent({:saved, channels})

        {:noreply,
         socket
         |> put_flash(:info, "Channels updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_channels(socket, :new, channels_params) do
    channels_params = Map.put(channels_params, "author", socket.assigns.myself.cid)

    case Accounts.create_channels(channels_params) do
      {:ok, channels} ->
        notify_parent({:saved, channels})

        {:noreply,
         socket
         |> put_flash(:info, "Channels created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
