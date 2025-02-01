defmodule RednewsWeb.ArticlesLive.Show do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Accounts

  require Logger

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn ->
        Accounts.get_user_by_session_token(session["user_token"])
      end)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    %{current_user: current_user} = socket.assigns

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:author, Accounts.get_user!(1))
     |> assign(:comments, Posts.get_comments(id, "article"))
     |> assign(:me_like, Posts.me_like?(id, :article, current_user.id))
     |> assign(:likes, Posts.likes(id, :article))
     |> assign(:articles, Posts.get_articles!(id))}
  end

  @impl true
  def handle_event("like_article", %{"id" => article_id}, socket) do
    %{current_user: current_user} = socket.assigns

    {article_id, ""} = Integer.parse(article_id)

    case Posts.like(article_id, :article, current_user.id) do
      {:ok, _} ->
        Logger.info("User #{current_user.id} liked article #{article_id}")

        socket =
          socket
          |> assign(
            me_like: Posts.me_like?(article_id, :article, current_user.id),
            likes: Posts.likes(article_id, :article)
          )

        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to like article #{article_id}: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to like the article.")}
    end
  end

  def handle_event("unlike_article", %{"id" => article_id}, socket) do
    %{current_user: current_user} = socket.assigns

    {article_id, ""} = Integer.parse(article_id)

    case Posts.unlike(article_id, :article, current_user.id) do
      {:ok, _} ->
        Logger.info("User #{current_user.id} unliked article #{article_id}")

        socket =
          socket
          |> assign(
            me_like: Posts.me_like?(article_id, :article, current_user.id),
            likes: Posts.likes(article_id, :article)
          )

        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to unlike article #{article_id}: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to unlike the article.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    article = Posts.get_articles!(id)
    {:ok, _} = Posts.delete_articles(article)

    {:noreply,
     socket
     |> push_navigate(to: "/articles")}
  end

  defp page_title(:show), do: "Show Articles"
  defp page_title(:edit), do: "Edit Articles"
end
