defmodule RednewsWeb.UsersLive.UserFeed do
  use RednewsWeb, :live_view

  alias Rednews.{Accounts, Posts}
  alias RednewsWeb.Helpers
  alias Rednews.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen pb-10 bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
      <div class="pt-16 pb-12 px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-4xl font-extrabold text-gray-900 dark:text-white mb-2">
          {gettext("Your Personal Feed")}
        </h1>
        <p class="text-lg text-gray-600 dark:text-gray-300">
          {gettext("Curated content from your subscriptions")}
        </p>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-8">
        <div class="flex overflow-x-auto pb-2 space-x-2 scrollbar-hide">
          <button
            phx-click="switch_tab"
            phx-value-tab="all"
            class={"px-6 py-2 rounded-full font-medium whitespace-nowrap transition-all #{if @active_tab == "all", do: "bg-indigo-600 text-white", else: "bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"}"}
          >
            {gettext("All Content")}
          </button>

          <%= for sub <- @subscriptions do %>
            <button
              phx-click="switch_tab"
              phx-value-tab={"#{sub.target_type}-#{sub.target_id}"}
              class={"px-6 py-2 rounded-full font-medium whitespace-nowrap transition-all flex items-center #{if @active_tab == "#{sub.target_type}-#{sub.target_id}", do: "bg-indigo-600 text-white", else: "bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"}"}
            >
              <%= if sub.target_type == "user" do %>
                <img
                  src={Map.get(sub, :user_avatar) || "/images/default-avatar.png"}
                  class="w-6 h-6 rounded-full mr-2 object-cover"
                />
                {Map.get(sub, :user_username) || "User"}
              <% else %>
                <img
                  src={Map.get(sub, :channel_logo) || "/images/default-channel.png"}
                  class="w-6 h-6 rounded-full mr-2 object-cover"
                />
                {Map.get(sub, :channel_name) || "Channel"}
              <% end %>
            </button>
          <% end %>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <%= if Enum.empty?(@feed_items) do %>
          <div class="text-center py-16">
            <div class="mx-auto h-24 w-24 text-gray-400 dark:text-gray-600">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            </div>
            <h3 class="mt-2 text-lg font-medium text-gray-900 dark:text-white">No content yet</h3>
            <p class="mt-1 text-gray-500 dark:text-gray-400">
              Start following users and channels to see their content here.
            </p>
          </div>
        <% else %>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <%= for item <- @feed_items do %>
              <.content_card item={item} />
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp content_card(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-md overflow-hidden hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
      <%= if @item.type == "article" do %>
        <.article_card article={@item.content} />
      <% else %>
        <.headline_card headline={@item.content} />
      <% end %>
    </div>
    """
  end

  defp article_card(assigns) do
    ~H"""
    <.link navigate={"/articles/article/#{@article.id}"}>
      <div class="relative h-48 overflow-hidden">
        <img
          src={@article.header || "/images/default-article.jpg"}
          class="w-full h-full object-cover"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        <div class="absolute top-3 left-3">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
            {gettext("Article")}
          </span>
        </div>
      </div>
      <div class="p-5">
        <div class="flex items-center mb-3">
          <img
            src={@article.user.avatar || "/images/default-avatar.png"}
            class="w-8 h-8 rounded-full mr-2"
          />
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {@article.user.username}
          </span>
        </div>
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 line-clamp-2">
          {@article.title}
        </h3>
        <p class="text-gray-500 dark:text-gray-400 text-sm line-clamp-3">
          {String.slice(@article.content, 0..100)}...
        </p>
        <div class="mt-4 flex justify-between items-center">
          <span class="text-xs text-gray-500">
            {@article.inserted_at}
          </span>
          <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300">
            {Gettext.gettext(RednewsWeb.Gettext, @article.category)}
          </span>
        </div>
      </div>
    </.link>
    """
  end

  defp headline_card(assigns) do
    ~H"""
    <.link navigate={"/news/headline/#{@headline.id}"}>
      <div class="relative h-48 overflow-hidden">
        <img src={@headline.header || "/images/default-news.jpg"} class="w-full h-full object-cover" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        <div class="absolute top-3 left-3">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
            {gettext("News")}
          </span>
        </div>
        <%= if @headline.is_very_important do %>
          <div class="absolute top-3 right-3 bg-red-500 text-white px-2 py-1 rounded-full text-xs font-bold">
            {gettext("Important")}
          </div>
        <% end %>
      </div>
      <div class="p-5">
        <div class="flex items-center mb-3">
          <img
            src={@headline.channel.logo || "/images/default-channel.png"}
            class="w-8 h-8 rounded-full mr-2"
          />
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {@headline.channel.name}
          </span>
        </div>
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 line-clamp-2">
          {@headline.title}
        </h3>
        <p class="text-gray-500 dark:text-gray-400 text-sm line-clamp-3">
          {String.slice(@headline.content, 0..100)}...
        </p>
        <div class="mt-4 flex justify-between items-center">
          <span class="text-xs text-gray-500">
            {@headline.inserted_at}
          </span>
          <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300">
            {Gettext.gettext(RednewsWeb.Gettext, @headline.category)}
          </span>
        </div>
      </div>
    </.link>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    current_user = Helpers.get_current_user(session)

    if current_user do
      subscriptions =
        Accounts.list_user_subscriptions(current_user.id)
        |> Enum.map(&load_subscription_details/1)

      feed_items = load_feed_items(subscriptions)

      socket =
        assign(socket,
          current_user: current_user,
          subscriptions: subscriptions,
          feed_items: feed_items,
          active_tab: "all"
        )

      {:ok, socket}
    else
      {:ok, redirect(socket, to: "/users/log_in")}
    end
  end

  defp load_subscription_details(subscription) do
    subscription =
      case subscription.target_type do
        "user" ->
          user = Accounts.get_user!(subscription.target_id)

          subscription
          |> Map.put(:user_avatar, user.avatar)
          |> Map.put(:user_username, user.username)
          |> Map.put(:has_channels, Accounts.user_has_channels?(user.id))

        "channel" ->
          channel = Accounts.get_channel!(subscription.target_id)

          subscription
          |> Map.put(:channel_logo, channel.logo)
          |> Map.put(:channel_name, channel.name)
      end

    subscription
    |> Map.put(:subscription_type, get_subscription_type(subscription))
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    subscriptions = socket.assigns.subscriptions

    feed_items =
      case tab do
        "all" ->
          load_feed_items(subscriptions)

        tab_str ->
          [type, id_str] = String.split(tab_str, "-")
          id = String.to_integer(id_str)

          sub =
            Enum.find(subscriptions, fn s ->
              s.target_type == type and s.target_id == id
            end)

          case type do
            "user" ->
              articles =
                if sub.subscribe_articles do
                  Posts.list_article(:author, %{user_id: id})
                  |> Repo.preload(:user)
                  |> Enum.map(&%{type: "article", content: &1})
                else
                  []
                end

              headlines =
                if sub.subscribe_channels do
                  channels = Accounts.list_channels(:author, %{user_id: id})
                  channel_ids = Enum.map(channels, & &1.id)

                  if Enum.empty?(channel_ids) do
                    []
                  else
                    Posts.list_headlines(:channel, %{channel_ids: channel_ids})
                    |> Repo.preload([:channel])
                    |> Enum.map(&%{type: "headline", content: &1})
                  end
                else
                  []
                end

              articles ++ headlines

            "channel" ->
              Posts.list_headlines(:channel, %{channel_id: id})
              |> Repo.preload([:channel])
              |> Enum.map(&%{type: "headline", content: &1})
          end
      end

    {:noreply,
     assign(socket,
       feed_items: feed_items,
       active_tab: tab
     )}
  end

  defp load_feed_items(subscriptions) do
    {user_subs, channel_subs} = Enum.split_with(subscriptions, &(&1.target_type == "user"))

    articles =
      Enum.reduce(user_subs, [], fn sub, acc ->
        if sub.subscribe_articles do
          user_articles =
            Posts.list_article(:author, %{user_id: sub.target_id})
            |> Repo.preload(:user)
            |> Enum.map(&%{type: "article", content: &1})

          acc ++ user_articles
        else
          acc
        end
      end)

    direct_channel_ids =
      Enum.map(channel_subs, & &1.target_id)
      |> MapSet.new()

    user_channel_news =
      Enum.reduce(user_subs, [], fn sub, acc ->
        if sub.subscribe_channels do
          user_channels = Accounts.list_channels(:author, %{user_id: sub.target_id})

          filtered_channels =
            Enum.reject(user_channels, fn channel ->
              MapSet.member?(direct_channel_ids, channel.id)
            end)

          channel_ids = Enum.map(filtered_channels, & &1.id)

          channel_news =
            if Enum.empty?(channel_ids) do
              []
            else
              Posts.list_headlines(:channel, %{channel_ids: channel_ids})
              |> Repo.preload([:channel])
              |> Enum.map(&%{type: "headline", content: &1})
            end

          acc ++ channel_news
        else
          acc
        end
      end)

    direct_channel_news =
      if Enum.empty?(channel_subs) do
        []
      else
        channel_ids = MapSet.to_list(direct_channel_ids)

        Posts.list_headlines(:channel, %{channel_ids: channel_ids})
        |> Repo.preload([:channel])
        |> Enum.map(&%{type: "headline", content: &1})
      end

    all_headlines = direct_channel_news ++ user_channel_news

    (articles ++ all_headlines)
    |> Enum.sort_by(& &1.content.inserted_at, {:desc, NaiveDateTime})
  end

  defp get_subscription_type(%{
         target_type: "user",
         subscribe_articles: true,
         subscribe_channels: true
       }),
       do: "all"

  defp get_subscription_type(%{target_type: "user", subscribe_articles: true}), do: "articles"
  defp get_subscription_type(%{target_type: "user", subscribe_channels: true}), do: "channels"
  defp get_subscription_type(%{target_type: "channel"}), do: "channel"
end
