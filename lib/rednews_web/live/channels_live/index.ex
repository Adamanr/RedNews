defmodule RednewsWeb.ChannelsLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Posts
  alias Rednews.Accounts.Channels

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:popular_channels, Accounts.list_channel())
      |> assign(:selected_category, nil)
      |> assign(:categories, Posts.list_categories())
      |> stream(:channels, Accounts.list_channel())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Channels")
    |> assign(:channels, Accounts.get_channels!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Channels")
    |> assign(:channels, %Channels{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Channel")
    |> assign(:channels, nil)
  end

  @impl true
  def handle_info({RednewsWeb.ChannelsLive.FormComponent, {:saved, channels}}, socket) do
    {:noreply, stream_insert(socket, :channel, channels)}
  end
end
