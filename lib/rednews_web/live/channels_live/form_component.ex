defmodule RednewsWeb.ChannelsLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Accounts
  alias Rednews.Posts
  alias RednewsWeb.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-8">
      <div class="bg-white dark:bg-gray-800/90 backdrop-blur-sm rounded-xl shadow-2xl overflow-hidden border border-gray-200 dark:border-gray-700 transition-all duration-300 hover:shadow-lg">
        <div class="bg-gradient-to-r from-blue-500 to-purple-600 dark:from-blue-800 dark:to-purple-800 p-6">
          <div class="flex items-center space-x-3">
            <svg
              class="h-8 w-8 text-white dark:text-gray-200"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <h1 class="text-2xl font-bold dark:text-gray-200 text-white">
              {gettext("Create New Channel")}
            </h1>
          </div>
          <p class="mt-1 text-blue-100 dark:text-gray-300">{gettext("Build your community space")}</p>
        </div>

        <div class="p-6 space-y-6">
          <.simple_form
            for={@form}
            id="channels-form"
            phx-change="validate"
            phx-target={@myself}
            phx-submit="save"
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {gettext("Channel Name")}
              </label>
              <.input
                field={@form[:name]}
                type="text"
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2"
                placeholder={gettext("Awesome Channel")}
              />
            </div>

            <div class="hidden">
              <.input field={@form[:user_id]} value={assigns.current_user.id} type="text" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Logo URL")}
                </label>
                <.input
                  field={@form[:logo]}
                  type="text"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2"
                  placeholder={gettext("https://example.com/logo.png")}
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Background Image URL")}
                </label>
                <.input
                  field={@form[:header]}
                  type="text"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2"
                  placeholder={gettext("https://example.com/header.jpg")}
                />
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Channel Link")}
                </label>
                <.input
                  field={@form[:links]}
                  type="text"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2"
                  placeholder={gettext("https://example.com/channel")}
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Category")}
                </label>
                <.input
                  field={@form[:category]}
                  type="select"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2"
                  options={Helpers.translate_options(Enum.map(Posts.list_categories(), & &1.value))}
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {gettext("Description")}
              </label>
              <.input
                field={@form[:desc]}
                type="textarea"
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 px-4 py-2 min-h-[120px]"
                placeholder={gettext("Tell people what your channel is about...")}
              />
            </div>

            <div class="pt-4 border-t border-gray-200 dark:border-gray-700">
              <.button
                class="w-full flex dark:text-gray-200 justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white bg-gradient-to-r from-blue-600 to-purple-600 dark:from-blue-800 dark:to-purple-800 hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 transform hover:scale-[1.02]"
                phx-disable-with={gettext("Creating...")}
              >
                {gettext("Create Channel")}
                <svg class="ml-2 -mr-1 w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 5l7 7-7 7M5 5l7 7-7 7"
                  />
                </svg>
              </.button>
            </div>
          </.simple_form>
        </div>
      </div>
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
    case Accounts.update_channels(socket.assigns.channels, channels_params) do
      {:ok, channels} ->
        notify_parent({:saved, channels})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Channels updated successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_channels(socket, :new, channels_params) do
    case Accounts.create_channels(channels_params) do
      {:ok, channels} ->
        notify_parent({:saved, channels})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Channels created successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
