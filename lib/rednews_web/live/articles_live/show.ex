defmodule RednewsWeb.ArticlesLive.Show do
  use RednewsWeb, :live_view

  require Logger

  alias Rednews.Posts
  alias Rednews.Accounts
  alias Rednews.Repo
  alias RednewsWeb.Helpers

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:current_user, Helpers.get_current_user(session))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    %{current_user: current_user} = socket.assigns

    me_like = if not is_nil(current_user), do: Posts.me_like?(id, :article, current_user.id), else: false

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:comments, Posts.get_comments(id, "article"))
     |> assign(:me_like, me_like)
     |> assign(:likes, Posts.likes(id, :article))
     |> assign(:article, Posts.get_articles!(id) |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("like_article", %{"id" => article_id}, socket) do
    %{current_user: current_user} = socket.assigns

    article_id = String.to_integer(article_id)

    case Posts.like(article_id, :article, current_user.id) do
      {:ok, _} ->
        Logger.info("User #{current_user.id} liked article #{article_id}")

        {:noreply,
         socket
         |> assign(me_like: Posts.me_like?(article_id, :article, current_user.id))
         |> assign(likes: Posts.likes(article_id, :article))}

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
