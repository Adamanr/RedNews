defmodule RednewsWeb.UsersLive.UserFeed do
  use RednewsWeb, :live_view

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl text-4xl py-10 text-center  text-white mx-auto"></div>
    """
  end

  @impl true
  def mount(_, _session, socket) do
    {:ok, socket}
  end
end
