defmodule RednewsWeb.UsersLive.UserProfile do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Posts

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl md:grid grid-cols-3 gap-5 mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="">
        <div class="relative flex items-center w-full items-center flex-shrink-0">
          <img
            src={@user.avatar || "/images/default-avatar.png"}
            class="items-center flex w-full mx-auto   rounded-lg object-cover "
            alt={@user.username}
          />

          <p class="absolute hover:bg-gradient-to-r from-blue-500 to-purple-500 hover:p-2 hover:rounded-full bottom-2 text-2xl right-2">
            {if not is_nil(@user.preferences), do: @user.preferences["emoji"], else: ""}
          </p>
        </div>
        <div class="mt-4 space-y-2">
          <div class="items-center flex space-x-2">
            <%= if @user.is_verified  do %>
              <div class="relative inline-flex group">
                <svg
                  <svg
                  alt="Пользователь подтверждён"
                  class="w-7 h-7"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                  <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                  <g id="SVGRepo_iconCarrier">
                    <path
                      fill-rule="evenodd"
                      clip-rule="evenodd"
                      d="M9.5924 3.20027C9.34888 3.4078 9.22711 3.51158 9.09706 3.59874C8.79896 3.79854 8.46417 3.93721 8.1121 4.00672C7.95851 4.03705 7.79903 4.04977 7.48008 4.07522C6.6787 4.13918 6.278 4.17115 5.94371 4.28923C5.17051 4.56233 4.56233 5.17051 4.28923 5.94371C4.17115 6.278 4.13918 6.6787 4.07522 7.48008C4.04977 7.79903 4.03705 7.95851 4.00672 8.1121C3.93721 8.46417 3.79854 8.79896 3.59874 9.09706C3.51158 9.22711 3.40781 9.34887 3.20027 9.5924C2.67883 10.2043 2.4181 10.5102 2.26522 10.8301C1.91159 11.57 1.91159 12.43 2.26522 13.1699C2.41811 13.4898 2.67883 13.7957 3.20027 14.4076C3.40778 14.6511 3.51158 14.7729 3.59874 14.9029C3.79854 15.201 3.93721 15.5358 4.00672 15.8879C4.03705 16.0415 4.04977 16.201 4.07522 16.5199C4.13918 17.3213 4.17115 17.722 4.28923 18.0563C4.56233 18.8295 5.17051 19.4377 5.94371 19.7108C6.278 19.8288 6.6787 19.8608 7.48008 19.9248C7.79903 19.9502 7.95851 19.963 8.1121 19.9933C8.46417 20.0628 8.79896 20.2015 9.09706 20.4013C9.22711 20.4884 9.34887 20.5922 9.5924 20.7997C10.2043 21.3212 10.5102 21.5819 10.8301 21.7348C11.57 22.0884 12.43 22.0884 13.1699 21.7348C13.4898 21.5819 13.7957 21.3212 14.4076 20.7997C14.6511 20.5922 14.7729 20.4884 14.9029 20.4013C15.201 20.2015 15.5358 20.0628 15.8879 19.9933C16.0415 19.963 16.201 19.9502 16.5199 19.9248C17.3213 19.8608 17.722 19.8288 18.0563 19.7108C18.8295 19.4377 19.4377 18.8295 19.7108 18.0563C19.8288 17.722 19.8608 17.3213 19.9248 16.5199C19.9502 16.201 19.963 16.0415 19.9933 15.8879C20.0628 15.5358 20.2015 15.201 20.4013 14.9029C20.4884 14.7729 20.5922 14.6511 20.7997 14.4076C21.3212 13.7957 21.5819 13.4898 21.7348 13.1699C22.0884 12.43 22.0884 11.57 21.7348 10.8301C21.5819 10.5102 21.3212 10.2043 20.7997 9.5924C20.5922 9.34887 20.4884 9.22711 20.4013 9.09706C20.2015 8.79896 20.0628 8.46417 19.9933 8.1121C19.963 7.95851 19.9502 7.79903 19.9248 7.48008C19.8608 6.6787 19.8288 6.278 19.7108 5.94371C19.4377 5.17051 18.8295 4.56233 18.0563 4.28923C17.722 4.17115 17.3213 4.13918 16.5199 4.07522C16.201 4.04977 16.0415 4.03705 15.8879 4.00672C15.5358 3.93721 15.201 3.79854 14.9029 3.59874C14.7729 3.51158 14.6511 3.40781 14.4076 3.20027C13.7957 2.67883 13.4898 2.41811 13.1699 2.26522C12.43 1.91159 11.57 1.91159 10.8301 2.26522C10.5102 2.4181 10.2043 2.67883 9.5924 3.20027ZM16.3735 9.86314C16.6913 9.5453 16.6913 9.03 16.3735 8.71216C16.0557 8.39433 15.5403 8.39433 15.2225 8.71216L10.3723 13.5624L8.77746 11.9676C8.45963 11.6498 7.94432 11.6498 7.62649 11.9676C7.30866 12.2854 7.30866 12.8007 7.62649 13.1186L9.79678 15.2889C10.1146 15.6067 10.6299 15.6067 10.9478 15.2889L16.3735 9.86314Z"
                      fill="#1C274C"
                    >
                    </path>
                  </g>
                </svg>
                <span class="sr-only">Пользователь подтверждён</span>
                <div class="absolute z-20 hidden group-hover:block px-2 py-1 text-xs text-white bg-gray-900 rounded-lg shadow-lg bottom-full left-1/2 transform -translate-x-1/2 mb-2 after:content-[''] after:absolute after:top-full after:left-1/2 after:-translate-x-1/2 after:border-4 after:border-transparent after:border-t-gray-900">
                  {gettext("The user is confirmed")}
                </div>
              </div>
            <% end %>
            <h1 class="text-2xl items-center font-bold text-gray-900">
              {@user.username}
              <span class="text-gray-600 text-sm">(@{@user.login})</span>
            </h1>
          </div>
          <p class="mt-2 text-gray-600">{@user.desc}</p>
          <div class="mt-4 flex flex-wrap gap-2">
            <%= for link <- @user.links || [] do %>
              <a href={link} class="text-blue-600 hover:text-blue-800 text-sm" target="_blank">
                {link}
              </a>
            <% end %>
          </div>
        </div>
        <%= if @user.id == @current_user.id do %>
          <div class="space-y-2">
            <.link href="/users/edit">
              <p class="border-2 rounded-md mb-2 text-center px-2 py-1 border-black">
                {gettext("Edit")}
              </p>
            </.link>
            <.link href="/users/log_out" method="DELETE">
              <p class="border-2 rounded-md text-center px-2 py-1 border-black">
                {gettext("Log out")}
              </p>
            </.link>
          </div>
        <% end %>
      </div>

      <div class="col-span-2 md:mt-0 mt-5">
        <.tabs
          tabs={[gettext("Articles"), gettext("News"), gettext("Channels")]}
          active_tab={@active_tab}
        >
          <:tab_content :let={tab_idx}>
            <%= case tab_idx do %>
              <% 0 -> %>
                <%= for article <- @articles do %>
                  <.link href={"/articles/article/#{article.id}"}>
                    <div class="relative bg-gradient-to-t from-black to-white/25 h-[25vh] rounded-2xl w-full">
                      <img
                        src={article.header}
                        alt="Article Image"
                        class="absolute z-0 h-full rounded-2xl w-full opacity-25 object-cover"
                      />
                      <div class="absolute bottom-0 px-4  ">
                        <p
                          class="bg-white px-4 py-1 font-bold rounded-2xl w-fit"
                          style="font-family: 'Merriweather', sans-serif;"
                        >
                          {Gettext.gettext(RednewsWeb.Gettext, article.category)}
                        </p>
                        <h1 class="text-xl text-white font-bold my-2 font-bold">{article.title}</h1>
                      </div>
                    </div>
                  </.link>
                <% end %>
              <% 1 -> %>
                <%= for headline <- @news do %>
                  <.link href={"/news/headline/#{headline.id}"}>
                    <div class="relative bg-gradient-to-t mb-5 from-black to-white/25 h-[25vh] rounded-2xl w-full">
                      <img
                        src={headline.header}
                        alt="Article Image"
                        class="absolute z-0 h-full rounded-2xl w-full opacity-25 object-cover"
                      />
                      <div class="absolute bottom-0 px-4  ">
                        <p
                          class="bg-white px-4 py-1 font-bold rounded-2xl w-fit"
                          style="font-family: 'Merriweather', sans-serif;"
                        >
                          {Gettext.gettext(RednewsWeb.Gettext, headline.category)}
                        </p>
                        <h1 class="text-xl text-white font-bold my-2 font-bold">{headline.title}</h1>
                      </div>
                    </div>
                  </.link>
                <% end %>
              <% 2 -> %>
                <%= for channel <- @channels do %>
                  <.link href={"/channels/channel/#{channel.id}"}>
                    <div class="relative bg-gradient-to-t mb-5 from-black to-white/25 h-[25vh] rounded-2xl w-full">
                      <img
                        src={channel.logo}
                        alt="Article Image"
                        class="absolute z-0 h-full rounded-2xl w-full opacity-25 object-cover"
                      />
                      <div class="absolute bottom-0 px-4  ">
                        <p
                          class="bg-white px-4 py-1 font-bold rounded-2xl w-fit"
                          style="font-family: 'Merriweather', sans-serif;"
                        >
                          {Gettext.gettext(RednewsWeb.Gettext, channel.category)}
                        </p>
                        <h1 class="text-xl text-white font-bold my-2 font-bold">{channel.name}</h1>
                      </div>
                    </div>
                  </.link>
                <% end %>
            <% end %>
          </:tab_content>
        </.tabs>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => user_id}, _session, socket) do
    user = Accounts.get_user!(user_id)

    articles = Posts.list_article(:author, %{user_id: user.id})
    news = Posts.list_user_headlines(user.id)
    channels = Accounts.list_channels(:author, %{user_id: user.id})

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
  def handle_params(%{"id" => user_id}, _, socket) do
    user_id = String.to_integer(user_id)

    user = Accounts.get_user!(user_id)
    channels = Accounts.list_user_channels(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:channels, channels)
      |> assign(:page_title, "#{user.username}'s Profile")
      |> assign(:current_tab, "overview")

    {:noreply, socket}
  end
end
