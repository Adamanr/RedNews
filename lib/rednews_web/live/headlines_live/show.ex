defmodule RednewsWeb.HeadlinesLive.Show do
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
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:author, Accounts.get_user!(1))
     |> assign(:me_like, Posts.me_like?(id, :headline, 1))
     |> assign(:likes, Posts.likes(id, :headline))
     |> assign(:headlines, Posts.get_headlines!(id))}
  end

  @doc """
  Handles the "like" event for liking an headline.

  ## Parameters
  - `"id"`: The ID of the headline to like.
  - `socket`: The current LiveView socket.

  ## Returns
  - Updates the socket with the new like status and count.
  - Logs the result and shows an error message if the operation fails.
  """
  @impl true
  def handle_event("like", %{"id" => pub_id}, socket) do
    %{current_user: current_user} = socket.assigns

    {pub_id, ""} = Integer.parse(pub_id)
    case Posts.like(pub_id, :headline, current_user.id) do
      {:ok, _} ->
        Logger.info("User #{current_user.id} liked headline #{pub_id}")
        socket =
          socket
          |> assign(
            me_like: Posts.me_like?(pub_id, :headline, current_user.id),
            likes: Posts.likes(pub_id, :headline)
          )

        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to like headline #{pub_id}: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to like the headline.")}
    end
  end

  @doc """
  Handles the "unlike" event for unliking an headline.

  ## Parameters
  - `"id"`: The ID of the headline to unlike.
  - `socket`: The current LiveView socket.

  ## Returns
  - Updates the socket with the new like status and count.
  - Logs the result and shows an error message if the operation fails.
  """
  @impl true
  def handle_event("unlike", %{"id" => pub_id}, socket) do
    %{current_user: current_user} = socket.assigns

    {pub_id, ""} = Integer.parse(pub_id)
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
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    headline = Posts.get_headlines!(id)
    {:ok, _} = Posts.delete_headlines(headline)

    {:noreply,
      socket
      |> push_navigate(to: "/news")}
  end

  defp page_title(:show), do: "Show Headlines"
  defp page_title(:edit), do: "Edit Headlines"
end
