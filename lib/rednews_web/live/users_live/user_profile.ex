defmodule RednewsWeb.UsersLive.UserProfile do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Posts
  alias RednewsWeb.Helpers
  alias Rednews.Repo

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen py-8 pb-40">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-white dark:bg-gray-800/90 backdrop-blur-sm shadow-2xl rounded-3xl overflow-hidden">
          <div class="relative">
            <div class={"h-48 md:h-64 bg-gradient-to-r #{elem(assigns.gradient, 0)} #{elem(assigns.gradient, 1)} relative"}>
              <div class="absolute inset-0 opacity-50 bg-pattern"></div>
              <div class="absolute bottom-0 left-0 right-0 h-1/2 bg-gradient-to-t from-white dark:from-gray-800 to-transparent">
              </div>
            </div>

            <div class="px-6 md:px-12 -mt-24 relative z-10">
              <div class="flex flex-col md:flex-row items-center md:items-end space-y-4 md:space-y-0 md:space-x-6">
                <div class="relative">
                  <div class="w-40 h-40 md:w-48 md:h-48 rounded-full ring-8 dark:ring-gray-700 ring-white shadow-2xl overflow-hidden">
                    <img
                      src={@user.avatar || "/images/default-avatar.png"}
                      class="w-full h-full object-cover"
                      alt={@user.username}
                    />
                    <%= if not is_nil(@user.preferences) do %>
                      <div class="absolute bottom-2 right-2 text-4xl">
                        {Map.get(@user.preferences, "emoji", "")}
                      </div>
                    <% end %>
                  </div>
                  <%= if @user.is_verified do %>
                    <div class="absolute bottom-2 -right-2 bg-gradient-to-br from-blue-500 to-cyan-400 text-white rounded-full p-1 shadow-lg">
                      <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                        <path
                          fill-rule="evenodd"
                          d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                        />
                      </svg>
                    </div>
                  <% end %>
                </div>

                <div class="text-center md:text-left flex-1">
                  <h1 class="text-3xl md:text-4xl dark:text-gray-200 font-black text-gray-900 flex items-center justify-center md:justify-start gap-2">
                    {@user.username}
                    <%= if @user.is_verified do %>
                      <span class="text-blue-500">
                        <svg class="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
                          <path
                            fill-rule="evenodd"
                            d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                          />
                        </svg>
                      </span>
                    <% end %>
                  </h1>
                  <p class="text-gray-600 dark:text-gray-300 mt-2 text-lg">@{@user.login}</p>
                </div>
              </div>

              <%= if @user.id == @current_user.id do %>
                <div class="mt-6 flex justify-center md:justify-start space-x-4">
                  <.link
                    href="/users/edit"
                    class="px-6 py-3 bg-gradient-to-r from-indigo-500 to-purple-600 text-white rounded-xl font-bold hover:from-indigo-600 hover:to-purple-700 transition-all"
                  >
                    {gettext("Edit Profile")}
                  </.link>
                  <.link
                    href="/users/log_out"
                    method="DELETE"
                    class="px-6 py-3 border-2 border-gray-300 dark:text-gray-400 dark:hover:bg-gray-700 text-gray-700 rounded-xl font-bold hover:bg-gray-100 transition-all"
                  >
                    {gettext("Log out")}
                  </.link>
                </div>
              <% end %>
            </div>

            <div class="px-6 md:px-12 mt-8">
              <div class="grid md:grid-cols-3 gap-8">
                <div class="md:col-span-2">
                  <h2 class="text-2xl font-bold text-gray-900 dark:text-gray-200 mb-4">
                    {gettext("About user")}
                  </h2>
                  <p class="text-gray-600 dark:text-gray-300 prose max-w-none">
                    {@user.desc || gettext("No description available")}
                  </p>

                  <%= if @current_user.id != @user.id do %>
                    <div class="mt-6">
                      <h3 class="text-xl font-bold text-gray-900 dark:text-gray-200 mb-3">
                        {gettext("Subscription Options")}
                      </h3>

                      <div class="flex flex-wrap pb-5 gap-3">
                        <%= if @subscribed_articles do %>
                          <button
                            phx-click="unsubscribe_articles"
                            phx-value-target={@user.id}
                            class="px-4 py-2 bg-red-100 text-red-800 rounded-lg hover:bg-red-200 transition-all flex items-center"
                          >
                            <svg
                              class="w-5 h-5 mr-2"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M20 12H4"
                              />
                            </svg>
                            {gettext("Unsubscribe from Articles")}
                          </button>
                        <% else %>
                          <button
                            phx-click="subscribe_articles"
                            phx-value-target={@user.id}
                            class="px-4 py-2 bg-indigo-100 text-indigo-800 rounded-lg hover:bg-indigo-200 transition-all flex items-center"
                          >
                            <svg
                              class="w-5 h-5 mr-2"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M12 4v16m8-8H4"
                              />
                            </svg>
                            {gettext("Subscribe to Articles")}
                          </button>
                        <% end %>

                        <%= if @subscribed_channels do %>
                          <button
                            phx-click="unsubscribe_channels"
                            phx-value-target={@user.id}
                            class="px-4 py-2 bg-red-100 text-red-800 rounded-lg hover:bg-red-200 transition-all flex items-center"
                          >
                            <svg
                              class="w-5 h-5 mr-2"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M20 12H4"
                              />
                            </svg>
                            {gettext("Unsubscribe from Channels")}
                          </button>
                        <% else %>
                          <button
                            phx-click="subscribe_channels"
                            phx-value-target={@user.id}
                            class="px-4 py-2 bg-purple-100 text-purple-800 rounded-lg hover:bg-purple-200 transition-all flex items-center"
                          >
                            <svg
                              class="w-5 h-5 mr-2"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M12 4v16m8-8H4"
                              />
                            </svg>
                            {gettext("Subscribe to Channels")}
                          </button>
                        <% end %>
                      </div>
                    </div>
                  <% end %>

                  <%= if @user.links && length(@user.links) > 0 do %>
                    <div class="mt-6">
                      <h3 class="text-xl font-bold text-gray-900 mb-3">{gettext("Links")}</h3>
                      <div class="flex flex-wrap gap-3">
                        <%= for link <- @user.links do %>
                          <a
                            href={link}
                            target="_blank"
                            class="px-4 py-2 bg-gray-100 text-gray-700 rounded-full hover:bg-indigo-100 hover:text-indigo-700 transition-all flex items-center"
                          >
                            <svg
                              class="w-5 h-5 mr-2"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                              />
                            </svg>
                            {link}
                          </a>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>

                <div class="bg-gray-50 dark:bg-gray-700 rounded-2xl p-6 space-y-4">
                  <h3 class="text-xl font-bold dark:text-gray-200 text-gray-900">
                    {gettext("User Stats")}
                  </h3>
                  <div class="grid grid-cols-3 gap-4">
                    <div class="text-center">
                      <div class="text-2xl font-black text-indigo-600">{length(@articles)}</div>
                      <div class="text-xs dark:text-gray-300 text-gray-500">
                        {gettext("Articles")}
                      </div>
                    </div>
                    <div class="text-center">
                      <div class="text-2xl font-black text-purple-600">{length(@news)}</div>
                      <div class="text-xs dark:text-gray-300 text-gray-500">{gettext("News")}</div>
                    </div>
                    <div class="text-center">
                      <div class="text-2xl font-black text-pink-600">{length(@channels)}</div>
                      <div class="text-xs dark:text-gray-300 text-gray-500">
                        {gettext("Channels")}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="px-6 pb-5 md:px-12">
              <.tabs
                tabs={[gettext("Articles"), gettext("News"), gettext("Channels")]}
                active_tab={@active_tab}
              >
                <:tab_content :let={tab_idx}>
                  <%= case tab_idx do %>
                    <% 0 -> %>
                      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <%= for article <- @articles do %>
                          <.link href={"/articles/article/#{article.id}"}>
                            <div class="bg-white dark:bg-gray-700/70 backdrop-blur-sm rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all group">
                              <div class="relative h-48 overflow-hidden">
                                <img
                                  src={article.header}
                                  alt="Article Image"
                                  class="w-full h-full object-cover transform group-hover:scale-110 transition-transform"
                                />
                                <div class="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent">
                                </div>
                              </div>
                              <div class="p-4">
                                <span class="inline-block bg-indigo-100 text-indigo-800 text-xs px-2 py-1 rounded-full mb-2">
                                  {Gettext.gettext(RednewsWeb.Gettext, article.category)}
                                </span>
                                <h2 class="text-lg font-bold text-gray-900 dark:text-gray-200 group-hover:text-indigo-600 transition-colors">
                                  {article.title}
                                </h2>
                              </div>
                            </div>
                          </.link>
                        <% end %>
                      </div>
                    <% 1 -> %>
                      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <%= for headline <- @news do %>
                          <.link href={"/news/headline/#{headline.id}"}>
                            <div class="bg-white dark:bg-gray-700/70 rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all group">
                              <div class="relative h-48 overflow-hidden">
                                <img
                                  src={headline.header}
                                  alt="News Image"
                                  class="w-full h-full object-cover transform group-hover:scale-110 transition-transform"
                                />
                                <div class="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent">
                                </div>
                              </div>
                              <div class="p-4">
                                <span class="inline-block bg-purple-100 text-purple-800 text-xs px-2 py-1 rounded-full mb-2">
                                  {Gettext.gettext(RednewsWeb.Gettext, headline.category)}
                                </span>
                                <h2 class="text-lg dark:text-gray-200 font-bold text-gray-900 group-hover:text-purple-600 transition-colors">
                                  {headline.title}
                                </h2>
                              </div>
                            </div>
                          </.link>
                        <% end %>
                      </div>
                    <% 2 -> %>
                      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <%= for channel <- @channels do %>
                          <.link href={"/channels/channel/#{channel.id}"}>
                            <div class="bg-white dark:bg-gray-700/70 rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all group">
                              <div class="relative h-48 overflow-hidden">
                                <img
                                  src={channel.logo}
                                  alt="Channel Image"
                                  class="w-full h-full object-cover transform group-hover:scale-110 transition-transform"
                                />
                                <div class="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent">
                                </div>
                              </div>
                              <div class="p-4">
                                <span class="inline-block bg-pink-100 text-pink-800 text-xs px-2 py-1 rounded-full mb-2">
                                  {Gettext.gettext(RednewsWeb.Gettext, channel.category)}
                                </span>
                                <h2 class="text-lg dark:text-gray-200 font-bold text-gray-900 group-hover:text-pink-600 transition-colors">
                                  {channel.name}
                                </h2>
                              </div>
                            </div>
                          </.link>
                        <% end %>
                      </div>
                  <% end %>
                </:tab_content>
              </.tabs>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => user_id}, session, socket) do
    user = Accounts.get_user!(user_id)
    articles = Posts.list_article(:author, %{user_id: user.id})
    news = Posts.list_user_headlines(user.id) |> Repo.preload(:channel)
    channels = Accounts.list_channels(:author, %{user_id: user.id}) |> Repo.preload(:user)
    current_user = Helpers.get_current_user(session)

    subscribed_articles =
      if current_user do
        Accounts.subscribed_to_user_articles?(current_user.id, user_id)
      else
        false
      end

    subscribed_channels =
      if current_user do
        Accounts.subscribed_to_user_channels?(current_user.id, user_id)
      else
        false
      end

    active_tab =
      cond do
        length(articles) > 0 -> 0
        length(news) > 0 -> 1
        length(channels) > 0 -> 2
        true -> 0
      end

    socket =
      socket
      |> assign(:user, user)
      |> assign(:tabs, ["Articles", "News", "Channels"])
      |> assign(:active_tab, active_tab)
      |> assign(:page_title, "#{user.username}'s Profile")
      |> assign(:articles, articles)
      |> assign(:news, news)
      |> assign(:subscribed_articles, subscribed_articles)
      |> assign(:subscribed_channels, subscribed_channels)
      |> assign(:current_user, current_user)
      |> assign(:gradient, Helpers.random_gradient())
      |> assign(:channels, channels)
      |> assign(:current_tab, Enum.at(["Articles", "News", "Channels"], active_tab))

    {:ok, socket}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    tab_idx = String.to_integer(tab)

    socket =
      socket
      |> assign(:active_tab, tab_idx)
      |> assign(:current_tab, Enum.at(socket.assigns.tabs, tab_idx))
      |> then(fn s ->
        case tab_idx do
          2 ->
            assign(s, :channels, Accounts.list_channels(:author, %{user_id: s.assigns.user.id}))

          1 ->
            assign(s, :news, Posts.list_user_headlines(s.assigns.user.id))

          0 ->
            assign(s, :articles, Posts.list_article(:author, %{user_id: s.assigns.user.id}))

          _ ->
            s
        end
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("subscribe_articles", %{"target" => target_user_id}, socket) do
    target_user_id = String.to_integer(target_user_id)

    case Accounts.subscribe_to_user_articles(socket.assigns.current_user.id, target_user_id) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Subscribed to articles"))
          |> assign(:subscribed_articles, true)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Subscription failed"))}
    end
  end

  @impl true
  def handle_event("unsubscribe_articles", %{"target" => target_user_id}, socket) do
    target_user_id = String.to_integer(target_user_id)

    case Accounts.unsubscribe_from_user_articles(socket.assigns.current_user.id, target_user_id) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Unsubscribed from articles"))
          |> assign(:subscribed_articles, false)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Unsubscription failed"))}
    end
  end

  @impl true
  def handle_event("subscribe_channels", %{"target" => target_user_id}, socket) do
    target_user_id = String.to_integer(target_user_id)

    case Accounts.subscribe_to_user_channels(socket.assigns.current_user.id, target_user_id) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Subscribed to channels"))
          |> assign(:subscribed_channels, true)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Subscription failed"))}
    end
  end

  @impl true
  def handle_event("unsubscribe_channels", %{"target" => target_user_id}, socket) do
    target_user_id = String.to_integer(target_user_id)

    case Accounts.unsubscribe_from_user_channels(socket.assigns.current_user.id, target_user_id) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, gettext("Unsubscribed from channels"))
          |> assign(:subscribed_channels, false)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Unsubscription failed"))}
    end
  end

  @impl true
  def handle_params(%{"id" => user_id}, _, socket) do
    user_id = String.to_integer(user_id)

    user = Accounts.get_user!(user_id)
    channels = Accounts.list_channels(:author, %{user_id: user_id}) |> Repo.preload(:user)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:channels, channels)
      |> assign(:page_title, "#{user.username}'s Profile")
      |> assign(:current_tab, "overview")

    {:noreply, socket}
  end
end
