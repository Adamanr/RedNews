defmodule RednewsWeb.ChannelsLive.Show do
  alias Rednews.Posts
  use RednewsWeb, :live_view

  require Logger

  alias Rednews.Accounts

  @impl true
  def mount(%{"id" => id}, session, socket) do
    channel = Accounts.get_channel!(id)

    {:ok,
     socket
     |> assign(:page_title, channel.name)
     |> assign(:channels, channel)
     |> assign(:current_user, Accounts.get_user_by_session_token(session["user_token"]))
     |> assign(:author, Accounts.get_user!(channel.author))
     |> assign(:headlines, Posts.list_headlines(:channel, %{channel: id}))
     |> assign(:show_full_desc, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:channels, Accounts.get_channels!(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    channels = Accounts.get_channels!(id)

    case Accounts.delete_channels(channels) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_navigate(to: "/channels")}

      {:error, reason} ->
        Logger.error("Failed to delete channels #{id}: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Failed to delete channels")}
    end
  end

  defp page_title(:show), do: "Show Channels"
  defp page_title(:edit), do: "Edit Channels"
end
