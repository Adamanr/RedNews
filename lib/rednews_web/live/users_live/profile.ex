defmodule RednewsWeb.UsersLive.Profile do
  use RednewsWeb, :live_view

  alias Rednews.Posts
  alias Rednews.Accounts

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
        <div class="flex items-start space-x-6">
          <div class="flex-shrink-0">
            <img
              src={@user.avatar || "/images/default-avatar.png"}
              class="h-32 w-32 rounded-full object-cover border-4 border-gray-200"
              alt={@user.username}
            />
          </div>
          <div class="flex-1">
            <div class="flex items-center space-x-4">
              <h1 class="text-2xl font-bold text-gray-900">
                <%= @user.username %>
                <%= if @user.is_verified do %>
                  <span class="inline-block ml-2">
                    <svg class="w-6 h-6 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"/>
                    </svg>
                  </span>
                <% end %>
              </h1>
              <span class="px-3 py-1 text-sm text-gray-600 bg-gray-100 rounded-full">
                <%= String.capitalize(@user.role) %>
              </span>
            </div>
            <p class="mt-2 text-gray-600"><%= @user.desc %></p>
            <div class="mt-4 flex flex-wrap gap-2">
              <%= for link <- @user.links || [] do %>
                <a href={link} class="text-blue-600 hover:text-blue-800 text-sm" target="_blank">
                  <%= link %>
                </a>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="space-y-6">
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-lg font-semibold mb-4">Preferences</h2>
            <div class="space-y-2">
              <%= for {key, value} <- @user.preferences || %{} do %>
                <div>
                  <dt class="text-sm font-medium text-gray-500">
                    <%= String.capitalize(to_string(key)) %>
                  </dt>
                  <dd class="mt-1 text-sm text-gray-900">
                    <%= inspect(value) %>
                  </dd>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => user_id}, _session, socket) do
    {user_id, ""} = Integer.parse(user_id)

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:page_title, "#{user.username}'s Profile")
      |> assign(:current_tab, "overview")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => user_id}, _, socket) do
    {user_id, ""} = Integer.parse(user_id)

    user = Accounts.get_user!(user_id)
    articles = Posts.list_user_articles(user_id)
    channels = Accounts.list_user_channels(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:articles, articles)
      |> assign(:channels, channels)
      |> assign(:page_title, "#{user.username}'s Profile")
      |> assign(:current_tab, "overview")

    {:noreply, socket}
  end

  defp page_title(:edit), do: "Edit Headlines"
end
