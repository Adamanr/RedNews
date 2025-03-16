defmodule RednewsWeb.ArticlesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias RednewsWeb.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white p-5 rounded-lg">
      <p class="font-bold text-xl">{gettext("Create article")}</p>

      <.simple_form
        for={@form}
        id="articles-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <.input field={@form[:header]} type="text" label={gettext("Article image URL")} />

        <div class="hidden">
          <.input
            field={@form[:user_id]}
            value={assigns.current_user.id}
            type="number"
            label={gettext("Author")}
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <.input
            field={@form[:tags]}
            type="text"
            label={gettext("Tags (Example: Games,News)")}
            value={Enum.join(@articles.tags || [], ", ")}
            placeholder={gettext("Games,News")}
          />
          <.input
            field={@form[:category]}
            type="select"
            label={gettext("Category")}
            options={Helpers.translate_options(Posts.list_categories())}
          />
        </div>

        <.input field={@form[:content]} type="textarea" label={gettext("Articles text")} rows="10" />

        <:actions>
          <div class="flex w-full">
            <div class="flex-1"></div>
            <.button class="bg-zinc-600 text-white font-bold flex-end" phx-disable-with="Saving...">
              {gettext("Publish")}
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{articles: articles, current_user: current_user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_user, current_user)
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
         |> put_flash(:info, "Articles #{action}d successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
