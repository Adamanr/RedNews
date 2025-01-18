defmodule RednewsWeb.HeadlinesLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Posts.Headlines

  @impl true
  def mount(_params, _session, socket) do

    socket =
      socket
      |> assign(:categories, Posts.list_categories)
      |> assign(:selected_category, "all")
      |> stream(:headlines, Posts.list_headlines())

    {:ok, socket}
  end

  @doc """
  Handles the "filtered" event for filtering headlines based on category or tags.

  ## Parameters
  - `"filter"`: A JSON-encoded string containing filter options and parameters.

  ## Returns
  - Updates the socket with the filtered headlines and resets the stream.
  """
  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_headlines(Posts.list_headlines(:category, %{category: category}))

        {"tags", tags} ->
          socket
          |> assign(:selected_tags, tags)
          |> assign_headlines(Posts.list_headlines(:tags, %{tags: tags}))

        {_, "tags"} ->
          socket
          |> assign(:selected_tags, "all")
          |> assign_headlines(Posts.list_headlines())

        {_, "category"} ->
          socket
          |> assign(:selected_category, "all")
          |> assign_headlines(Posts.list_headlines())

        _ ->
          socket
          |> assign_headlines(Posts.list_headlines())
      end

    {:noreply, stream(socket, :headlines, socket.assigns[:headline], reset: true)}
  end

  defp assign_headlines(socket, headlines) do
    assign(socket, :headline, headlines)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Headlines")
    |> assign(:headlines, Posts.get_headlines!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Headlines")
    |> assign(:headlines, %Headlines{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Headlines")
    |> assign(:headlines, nil)
  end

  @impl true
  def handle_info({RednewsWeb.HeadlinesLive.FormComponent, {:saved, headlines}}, socket) do
    {:noreply, stream_insert(socket, :headlines, headlines)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    headlines = Posts.get_headlines!(id)
    {:ok, _} = Posts.delete_headlines(headlines)

    {:noreply, stream_delete(socket, :headlines, headlines)}
  end
end
