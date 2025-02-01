defmodule RednewsWeb.ArticlesLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Posts.Articles

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:selected_category, "all")
      |> assign(:selected_tag, "all")
      |> assign(:categories, Posts.list_categories())
      |> stream(:article, Posts.list_article())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @doc """
  Handles incoming messages, such as notifications from child components.

  ## Parameters
  - `{RednewsWeb.ArticlesLive.FormComponent, {:saved, articles}}`: A message indicating that an article was saved.
  - `socket`: The current LiveView socket.

  ## Returns
  - Updates the socket by inserting the saved article into the stream.
  """
  @impl true
  def handle_info({RednewsWeb.ArticlesLive.FormComponent, {:saved, articles}}, socket) do
    {:noreply, stream_insert(socket, :article, articles)}
  end

  @doc """
  Handles the "filtered" event for filtering articles based on category or tags.

  ## Parameters
  - `"filter"`: A JSON-encoded string containing filter options and parameters.

  ## Returns
  - Updates the socket with the filtered articles and resets the stream.
  """
  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_articles(Posts.list_article(:category, %{category: category}))

        {"tags", tags} ->
          socket
          |> assign(:selected_tags, tags)
          |> assign_articles(Posts.list_article(:tags, %{tags: tags}))

        {_, "tags"} ->
          socket
          |> assign(:selected_tags, "all")
          |> assign_articles(Posts.list_article())

        {_, "category"} ->
          socket
          |> assign(:selected_category, "all")
          |> assign_articles(Posts.list_article())

        _ ->
          socket
          |> assign_articles(Posts.list_article())
      end

    {:noreply, stream(socket, :article, socket.assigns[:articles], reset: true)}
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    articles = Posts.search_articles(query)

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> stream(:article, articles, reset: true)}
  end

  defp assign_articles(socket, articles) do
    assign(socket, :articles, articles)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Articles")
    |> assign(:articles, Posts.get_articles!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Articles")
    |> assign(:articles, %Articles{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Article")
    |> assign(:articles, nil)
  end
end
