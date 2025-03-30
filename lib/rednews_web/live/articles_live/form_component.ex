defmodule RednewsWeb.ArticlesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias RednewsWeb.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="bg-white dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl overflow-hidden border border-gray-200 dark:border-gray-700">
        <div class="bg-gradient-to-r from-indigo-500 dark:from-indigo-900 dark:to-purple-900 to-purple-600 p-6">
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
                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
              />
            </svg>
            <h1 class="text-2xl font-bold text-white dark:text-gray-200">
              {gettext("Create New Article")}
            </h1>
          </div>
          <p class="mt-1 text-indigo-100 dark:text-gray-300">
            {gettext("Share your knowledge with the world")}
          </p>
        </div>

        <div class="p-6 sm:p-8">
          <.simple_form
            for={@form}
            id="articles-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <div class="space-y-2">
              <.input
                field={@form[:title]}
                type="text"
                label={gettext("Title")}
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm transition duration-200"
                placeholder={gettext("Catchy headline that grabs attention")}
              />
            </div>

            <div class="space-y-2">
              <.input
                field={@form[:header]}
                type="text"
                label={gettext("Featured Image URL")}
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm transition duration-200"
                placeholder={gettext("https://example.com/image.jpg")}
              />
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {gettext("Use high-quality image for better engagement")}
              </p>
            </div>

            <div class="hidden">
              <.input field={@form[:user_id]} value={assigns.current_user.id} type="number" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="space-y-2">
                <.input
                  field={@form[:tags]}
                  type="text"
                  phx-update="ignore"
                  id="article-tags-container"
                  label={gettext("Tags")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm transition duration-200"
                  value={Enum.join(@articles.tags || [], ", ")}
                  placeholder={gettext("Games, News, Technology")}
                />
                <p class="text-xs text-gray-500 dark:text-gray-400">
                  {gettext("Separate tags with commas")}
                </p>
              </div>

              <div class="space-y-2">
                <.input
                  field={@form[:category]}
                  type="select"
                  label={gettext("Category")}
                  class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm transition duration-200"
                  options={Helpers.translate_options(Enum.map(Posts.list_categories(), & &1.value))}
                />
              </div>
            </div>

            <div class="space-y-2" phx-update="ignore" id="article-content-container">
              <.input
                field={@form[:content]}
                type="textarea"
                label={gettext("Article Content")}
                class="mt-1 block w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-800 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm transition duration-200 min-h-[300px]"
                rows="15"
                placeholder={gettext("Write your amazing content here...")}
              />
            </div>

            <:actions>
              <div class="flex w-full items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-700">
                <div class="flex-1 flex items-center space-x-3">
                  <svg
                    class="h-5 w-5 text-gray-400"
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
                  <span class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Your article will be visible to everyone")}
                  </span>
                </div>
                <.button
                  class="inline-flex flex-end items-center px-6 py-3 border border-transparent text-base font-medium rounded-full shadow-sm text-white dark:text-gray-200 bg-gradient-to-r from-indigo-600 to-purple-600  dark:from-indigo-900 dark:to-purple-900 hover:from-indigo-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 transform hover:scale-105"
                  phx-disable-with={gettext("Publishing...")}
                >
                  {gettext("Publish Article")}
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
                      d="M13 5l7 7-7 7M5 5l7 7-7 7"
                    />
                  </svg>
                </.button>
              </div>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{articles: articles, current_user: current_user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_user, current_user)
     |> assign(
       :categories,
       Helpers.translate_options(Enum.map(Posts.list_categories(), & &1.label))
     )
     |> assign_new(:form, fn -> to_form(Posts.change_articles(articles)) end)}
  end

  @impl true
  def handle_event("validate", %{"articles" => articles_params}, socket) do
    changeset = Posts.change_articles(socket.assigns.articles, articles_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"articles" => articles_params}, socket) do
    case socket.assigns.action do
      :edit -> save_and_notify(socket, :update, socket.assigns.articles, articles_params)
      :new -> save_and_notify(socket, :create, articles_params)
    end
  end

  defp save_and_notify(socket, action, articles_or_params, articles_params \\ nil) do
    save_fn = if action == :update, do: &Posts.update_articles/2, else: &Posts.create_articles/1

    args =
      if action == :update, do: [articles_or_params, articles_params], else: [articles_or_params]

    case apply(save_fn, args) do
      {:ok, articles} ->
        notify_parent({:saved, articles})

        {:noreply,
         socket
         |> put_flash(
           :info,
           Gettext.gettext(RednewsWeb.Gettext, "Articles #{action}d successfully")
         )
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
