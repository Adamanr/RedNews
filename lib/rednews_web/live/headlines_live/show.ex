defmodule RednewsWeb.HeadlinesLive.Show do
  use RednewsWeb, :live_view

  require Logger

  alias Rednews.Repo
  alias Rednews.Posts
  alias RednewsWeb.Helpers

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, :current_user, Helpers.get_current_user(session))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    headline = Posts.get_headlines!(id) |> Repo.preload(:channel)

    me_like =
      if not is_nil(socket.assigns.current_user),
        do: Posts.me_like?(id, :headline, socket.assigns.current_user.id),
        else: false

    {:noreply,
     socket
     |> assign(:page_title, headline.title)
     |> assign(:likes, Posts.likes(id, :headline))
     |> assign(:me_like, me_like)
     |> assign(:headline, headline)}
  end

  @impl true
  def handle_event("like", %{"id" => pub_id}, socket) do
    %{current_user: current_user} = socket.assigns

    case Integer.parse(pub_id) do
      {pub_id, ""} ->
        case Posts.like(pub_id, :headline, current_user.id) do
          {:ok, _} ->
            Logger.info("User #{current_user.id} liked headline #{pub_id}")

            {:noreply,
             socket
             |> assign(me_like: Posts.me_like?(pub_id, :headline, current_user.id))
             |> assign(likes: Posts.likes(pub_id, :headline))}

          {:error, reason} ->
            Logger.error("Failed to like headline #{pub_id}: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Failed to like the headline.")}
        end

      _ ->
        Logger.error("Invalid pub_id format: #{pub_id}")
        {:noreply, put_flash(socket, :error, "Invalid headline ID.")}
    end
  end

  @impl true
  def handle_event("unlike", %{"id" => pub_id}, socket) do
    %{current_user: current_user} = socket.assigns

    case Integer.parse(pub_id) do
      {pub_id, ""} ->
        case Posts.unlike(pub_id, :headline, current_user.id) do
          {:ok, _} ->
            Logger.info("User #{current_user.id} unliked headline #{pub_id}")

            socket =
              socket
              |> assign(
                me_like: Posts.me_like?(pub_id, :headline, current_user.id),
                likes: Posts.likes(pub_id, :headline)
              )

            {:noreply, socket}

          {:error, reason} ->
            Logger.error("Failed to unlike headline #{pub_id}: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Failed to unlike the headline.")}
        end

      _ ->
        Logger.error("Invalid pub_id format: #{pub_id}")
        {:noreply, put_flash(socket, :error, "Invalid headline ID.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    headline = Posts.get_headlines!(id)

    case Posts.delete_headlines(headline) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_navigate(to: "/news")}

      {:error, reason} ->
        Logger.error("Failed to delete headline #{id}: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to unlike the headline.")}
    end
  end
end
