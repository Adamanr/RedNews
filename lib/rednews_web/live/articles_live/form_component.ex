defmodule RednewsWeb.ArticlesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage articles records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="articles-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Заголовок" />
        <.input field={@form[:content]} type="textarea" label="Контент (Markdown)" rows="10" />
        <.input field={@form[:tags]} type="text" label="Тэги (через запятую)" value={Enum.join(@articles.tags || [], ", ")}  placeholder="Игры, Новости" />
        <.input
          field={@form[:category]}
          type="select"
          label="Категория"
          options={Posts.list_categories}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Articles</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @moduledoc """
  LiveView module for handling article updates and validations.
  """

  @impl true
  def update(%{articles: articles} = assigns, socket) do
    {:ok,
    socket
    |> assign(assigns)
    |> assign_new(:form, fn -> to_form(Posts.change_articles(articles)) end)}
  end

  @doc """
  Handles the "validate" event for article form validation.

  ## Parameters
  - `"articles"`: A map containing the article parameters to validate.

  ## Returns
  - Updates the form in the socket with validation results.
  """
  @impl true
  def handle_event("validate", %{"articles" => articles_params}, socket) do
    articles_params = Map.delete(articles_params, "tags")
    changeset = Posts.change_articles(socket.assigns.articles, articles_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end


  @doc """
  Handles the "save" event for saving article data.

  ## Parameters
  - `"articles"`: A map containing the article parameters to save.

  ## Returns
  - Saves the article and notifies the parent process.
  - Redirects or shows validation errors based on the result.
  """
  @impl true
  def handle_event("save", %{"articles" => articles_params}, socket) do
    articles_params = Map.put(articles_params, "author", socket.assigns.myself.cid)

    case socket.assigns.action do
      :edit -> save_and_notify(socket, :update, socket.assigns.articles, articles_params)
      :new -> save_and_notify(socket, :create, articles_params)
    end
  end

  @doc """
  Saves the article and notifies the parent process.

  ## Parameters
  - `socket`: The current LiveView socket.
  - `action`: The action to perform (`:update` or `:create`).
  - `articles_or_params`: Either the existing article (for update) or the article parameters (for create).

  ## Returns
  - Updates the socket with a success message or validation errors.
  """
  defp save_and_notify(socket, action, articles_or_params, articles_params \\ nil) do
    save_fn = if action == :update, do: &Posts.update_articles/2, else: &Posts.create_articles/1
    args = if action == :update, do: [articles_or_params, articles_params], else: [articles_or_params]

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
