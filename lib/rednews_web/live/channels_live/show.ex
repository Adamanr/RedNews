defmodule RednewsWeb.ChannelsLive.Show do
  use RednewsWeb, :live_view

  alias Rednews.Accounts

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    channel = Accounts.get_channel!(id)
    author = Accounts.get_user!(channel.author)

    socket =
      socket
      |> assign(:page_title, channel.name)
      |> assign(:channels, channel)
      |> assign(:author, author)
      |> assign(:show_full_desc, false)

    {:ok, socket}
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
    {:ok, _} = Accounts.delete_channels(channels)

    {:noreply,
    socket
    |> push_navigate(to: "/articles")}
  end

  defp page_title(:show), do: "Show Channels"
  defp page_title(:edit), do: "Edit Channels"
end
