defmodule RednewsWeb.ArticlesLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Repo
  alias Rednews.Accounts
  alias Rednews.Posts.Articles
  alias Rednews.Posts.Headlines
  alias RednewsWeb.Helpers

  @impl true
  def mount(_params, session, socket) do
    articles = Posts.list_article() |> Repo.preload(:user)

    socket =
      socket
      |> assign(:first_article, hd(articles))
      |> assign(:current_user, Helpers.get_current_user(session))
      |> assign(:categories, Posts.list_categories())
      |> assign(:selected_category, "all")
      |> assign(:selected_date, "all")
      |> stream(:article, articles)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({RednewsWeb.ArticlesLive.FormComponent, {:saved, articles}}, socket) do
    {:noreply, stream_insert(socket, :article, articles)}
  end

  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_articles(Posts.list_article(:category_and_date, %{category: category}) |> Repo.preload(:user))

        {"tags", tags} ->
          socket
          |> assign(:selected_tags, tags)
          |> assign_articles(Posts.list_article(:tags, %{tags: tags}) |> Repo.preload(:user))

        {"date", date} ->
          socket
          |> assign(:selected_date, date)
          |> assign_articles(Posts.list_article(:category_and_date, %{category: socket.assigns[:selected_category], date: date}) |> Repo.preload(:user))

        {_, "tags"} ->
          socket
          |> assign(:selected_tags, "all")
          |> assign_articles(Posts.list_article() |> Repo.preload(:user))

        {_, "category"} ->
          socket
          |> assign(:selected_category, "all")
          |> assign_articles(Posts.list_article() |> Repo.preload(:user))

        _ ->
          socket
          |> assign_articles(Posts.list_article() |> Repo.preload(:user))
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
