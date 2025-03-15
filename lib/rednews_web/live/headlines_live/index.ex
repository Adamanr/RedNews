defmodule RednewsWeb.HeadlinesLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Repo
  alias Rednews.Accounts
  alias RednewsWeb.Helpers
  alias Rednews.Posts.Headlines

  @impl true
  def mount(_params, session, socket) do
    headlines = Posts.list_headlines() |> Repo.preload(:channel)

    {:ok,
      socket
      |> assign(:first_headline, Enum.at(headlines, 0))
      |> assign(:current_user, Helpers.get_current_user(session))
      |> assign(:categories, Posts.list_categories())
      |> assign(:selected_category, "all")
      |> assign(:selected_date, "all")
      |> stream(:headlines, headlines)}
  end

  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_headlines(Posts.list_headlines(:category_and_date, %{category: category, date: socket.assigns[:selected_date]}) |> Repo.preload(:channel))

        {"tags", tags} ->
          socket
          |> assign(:selected_tags, tags)
          |> assign_headlines(Posts.list_headlines(:tags, %{tags: tags}) |> Repo.preload(:channel))

        {"date", date} ->
          socket
          |> assign(:selected_date, date)
          |> assign_headlines(Posts.list_headlines(:category_and_date, %{category: socket.assigns[:selected_category], date: date}) |> Repo.preload(:channel))

        {_, "tags"} ->
          socket
          |> assign(:selected_tags, "all")
          |> assign_headlines(Posts.list_headlines())

        {_, "category"} ->
          socket
          |> assign(:selected_category, "all")
          |> assign_headlines(Posts.list_headlines())

        {_, "date"} ->
          socket
          |> assign(:selected_date, "all")
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
    |> assign(:page_title, "Добавить новость")
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
end
