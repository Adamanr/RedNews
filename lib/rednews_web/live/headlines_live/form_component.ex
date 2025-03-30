defmodule RednewsWeb.HeadlinesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias Rednews.Accounts
  alias RednewsWeb.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="bg-white dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl overflow-hidden border border-gray-200 dark:border-gray-700 transition-all duration-300 hover:shadow-lg">
        <div class="bg-gradient-to-r from-red-500 dark:from-red-700 dark:to-orange-800 to-orange-500 p-6">
          <div class="flex items-center space-x-3">
            <svg
              class="h-8 w-8 dark:text-gray-200 text-white"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"
              />
            </svg>
            <h1 class="text-2xl font-bold dark:text-gray-200 text-white">
              {gettext("Create Breaking News")}
            </h1>
          </div>
          <p class="mt-1 text-red-100 dark:text-gray-300">
            {gettext("Share the latest updates with the world")}
          </p>
        </div>

        <div class="p-6 space-y-6">
          <.simple_form
            for={@form}
            id="headlines-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {gettext("Title")} <span class="text-red-500">*</span>
              </label>
              <.input
                field={@form[:title]}
                type="text"
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-3 text-lg font-medium"
                placeholder={gettext("Breaking: Major development...")}
              />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Category")}
                </label>
                <.input
                  field={@form[:category]}
                  type="select"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-2"
                  options={Helpers.translate_options(Enum.map(Posts.list_categories(), & &1.value))}
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Tags")}
                  <span class="text-gray-400 text-xs">({gettext("comma separated")})</span>
                </label>
                <.input
                  field={@form[:tags]}
                  type="text"
                  phx-update="ignore"
                  id="headlines-tags-container"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-2"
                  value={Enum.join(@headlines.tags || [], ", ")}
                  placeholder={gettext("Politics, Economy, Technology")}
                />
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <%= if length(Accounts.list_user_channels(assigns.current_user.id)) == 0 do %>
                <div class="md:col-span-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-700 rounded-lg p-4">
                  <div class="flex items-center space-x-2 text-red-600 dark:text-red-300">
                    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                      />
                    </svg>
                    <p>
                      {gettext("You need a channel to publish news!")}
                      <.link
                        href="/channels/new"
                        class="ml-2 text-blue-600 dark:text-blue-400 hover:underline"
                      >
                        {gettext("Create one now")}
                      </.link>
                    </p>
                  </div>
                </div>
              <% else %>
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    {gettext("Publish in channel")}
                  </label>
                  <.input
                    field={@form[:channel_id]}
                    type="select"
                    class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-2"
                    options={
                      Enum.map(
                        Accounts.list_user_channels(assigns.current_user.id),
                        &{&1.name, &1.id}
                      )
                    }
                  />
                </div>
              <% end %>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  {gettext("Featured Image URL")}
                </label>
                <.input
                  field={@form[:header]}
                  type="text"
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-2"
                  placeholder={gettext("https://example.com/news-image.jpg")}
                />
                <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                  {gettext("Recommended size: 1200x630px")}
                </p>
              </div>
            </div>

            <div phx-update="ignore" id="article-content-container">
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {gettext("News Content")} <span class="text-red-500">*</span>
              </label>
              <.input
                field={@form[:content]}
                type="textarea"
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 transition duration-200 px-4 py-3 min-h-[300px]"
                rows="10"
                placeholder={gettext("Write your news story here...")}
              />
            </div>

            <div class="pt-6 border-t border-gray-200 dark:border-gray-700">
              <.button
                class="w-full flex dark:text-gray-200 justify-center items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white bg-gradient-to-r from-red-600 dark:from-red-800 dark:to-orange-800 to-orange-600 hover:from-red-700 hover:to-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-all duration-200 transform hover:scale-[1.02]"
                phx-disable-with={gettext("Publishing...")}
              >
                {gettext("Publish News")}
                <svg class="ml-2 -mr-1 w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
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
         |> put_flash(
           :ok,
           Gettext.gettext(RednewsWeb.Gettext, "Headlines #{action}d successfully")
         )
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
