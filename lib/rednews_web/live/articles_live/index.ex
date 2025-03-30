defmodule RednewsWeb.ArticlesLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Repo
  alias Rednews.Posts.Articles
  alias RednewsWeb.Helpers
  use Gettext, backend: RednewsWeb.Gettext

  @impl true
  def mount(_params, session, socket) do
    articles = Posts.list_article() |> Repo.preload(:user)

    first_article = if length(articles) > 0, do: hd(articles), else: nil

    socket =
      socket
      |> assign(:first_article, first_article)
      |> assign(:current_user, Helpers.get_current_user(session))
      |> assign(:selected_category, "all")
      |> assign(:search_term, "")
      |> assign(:selected_tags, "")
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
  def handle_event("search_articles", %{"value" => search_term}, socket) do
    socket =
      if String.length(search_term) > 0 do
        socket
        |> assign(:search_term, search_term)
        |> assign_articles(
          Posts.list_article(:search, %{search_term: search_term})
          |> Repo.preload(:user)
        )
      else
        socket
        |> assign(:search_term, nil)
        |> assign_articles(Posts.list_article() |> Repo.preload(:user))
      end

    {:noreply, stream(socket, :article, socket.assigns[:articles], reset: true)}
  end

  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_articles(
            Posts.list_article(:category_and_date, %{
              category: category,
              date: socket.assigns[:selected_date]
            })
            |> Repo.preload(:user)
          )

        {"tags", tag} ->
          socket
          |> assign(:selected_tags, tag)
          |> assign_articles(Posts.list_article(:tags, %{tags: tag}) |> Repo.preload(:user))

        {"date", date} ->
          socket
          |> assign(:selected_date, date)
          |> assign_articles(
            Posts.list_article(:category_and_date, %{
              category: socket.assigns[:selected_category],
              date: date
            })
            |> Repo.preload(:user)
          )

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
