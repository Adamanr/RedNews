defmodule RednewsWeb.ChannelsLive.Show do
  use RednewsWeb, :live_view

  require Logger

  alias Rednews.{Accounts, Posts}
  alias Rednews.Repo
  alias RednewsWeb.Helpers

  @impl true
  def mount(%{"id" => id}, session, socket) do
    channel = Accounts.get_channel!(id) |> Repo.preload(:user)
    current_user = Helpers.get_current_user(session)

    subscribed =
      if current_user do
        Accounts.subscribed_to_channel?(current_user.id, String.to_integer(id))
      else
        false
      end

    {:ok,
     socket
     |> assign(:page_title, channel.name)
     |> assign(:channel, channel)
     |> assign(:current_user, current_user)
     |> assign(:headlines, Posts.list_headlines(:channel, %{channel_id: String.to_integer(id)}))
     |> assign(:show_full_desc, false)
     |> assign(:subscribed, subscribed)}
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
        {:noreply, put_flash(socket, :error, gettext("Failed to delete channels"))}
    end
  end

  @impl true
  def handle_event("toggle_subscription", _, %{assigns: %{current_user: nil}} = socket) do
    {:noreply, put_flash(socket, :error, gettext("You need to log in first"))}
  end

  @impl true
  def handle_event(
        "toggle_subscription",
        _,
        %{assigns: %{current_user: user, channel: channel, subscribed: subscribed}} = socket
      ) do
    if subscribed do
      case Accounts.unsubscribe_from_channel(user.id, channel.id) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, gettext("Unsubscribed from channel"))
           |> assign(:subscribed, false)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, gettext("Failed to unsubscribe"))}
      end
    else
      case Accounts.subscribe_to_channel(user.id, channel.id) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, gettext("Subscribed to channel"))
           |> assign(:subscribed, true)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, gettext("Failed to subscribe"))}
      end
    end
  end

  defp page_title(:show), do: "Show Channels"
  defp page_title(:edit), do: "Edit Channels"
end
