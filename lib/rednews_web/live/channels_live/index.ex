defmodule RednewsWeb.ChannelsLive.Index do
  use RednewsWeb, :live_view

  alias Rednews.Accounts
  alias Rednews.Posts
  alias Rednews.Repo
  alias Rednews.Accounts.Channels
  alias RednewsWeb.Helpers

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:popular_channels, Accounts.list_channels())
      |> assign(:selected_category, "all")
      |> assign(:selected_date, "all")
      |> assign(:current_user, Helpers.get_current_user(session))
      |> assign(:categories, Posts.list_categories())
      |> stream(:channels, Accounts.list_channels())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("filtred", %{"filter" => filter}, socket) do
    %{"options" => options, "params" => params} = Jason.decode!(filter)

    socket =
      case {options, params} do
        {"category", category} ->
          socket
          |> assign(:selected_category, category)
          |> assign_channels(
            Accounts.list_channels(:category_and_date, %{
              category: category,
              date: socket.assigns[:selected_date]
            })
            |> Repo.preload(:user)
          )

        {"tags", tags} ->
          socket
          |> assign(:selected_tags, tags)
          |> assign_channels(Accounts.list_channels(:tags, %{tags: tags}) |> Repo.preload(:user))

        {"date", date} ->
          socket
          |> assign(:selected_date, date)
          |> assign_channels(
            Accounts.list_channels(:category_and_date, %{
              category: socket.assigns[:selected_category],
              date: date
            })
            |> Repo.preload(:user)
          )

        {_, "tags"} ->
          socket
          |> assign(:selected_tags, "all")
          |> assign_channels(Accounts.list_channels() |> Repo.preload(:user))

        {_, "category"} ->
          socket
          |> assign(:selected_category, "all")
          |> assign_channels(Accounts.list_channels() |> Repo.preload(:user))

        {_, "date"} ->
          socket
          |> assign(:selected_date, "all")
          |> assign_channels(Accounts.list_channels() |> Repo.preload(:user))

        _ ->
          socket
          |> assign_channels(Accounts.list_channels() |> Repo.preload(:user))
      end

    {:noreply, stream(socket, :channels, socket.assigns[:channels], reset: true)}
  end

  @impl true
  def handle_event("search_channels", %{"value" => search_term}, socket) do
    socket =
      if String.length(search_term) > 0 do
        socket
        |> assign(:search_term, search_term)
        |> assign_channels(
          Accounts.list_channels(:search, %{search_term: search_term})
          |> Repo.preload(:user)
        )
      else
        socket
        |> assign(:search_term, nil)
        |> assign_channels(Accounts.list_channels() |> Repo.preload(:user))
      end

    {:noreply, stream(socket, :channels, socket.assigns[:channels], reset: true)}
  end

  defp assign_channels(socket, channels) do
    assign(socket, :channels, channels)
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
