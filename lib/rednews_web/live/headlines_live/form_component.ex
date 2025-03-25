defmodule RednewsWeb.HeadlinesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias Rednews.Accounts
  alias RednewsWeb.Helpers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white p-5 rounded-lg">
      <p class="font-bold text-xl">{gettext("Create news")}</p>

      <.simple_form
        for={@form}
        id="headlines-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <div class="grid grid-cols-2 gap-5">
          <.input
            field={@form[:category]}
            type="select"
            label={gettext("Category")}
            options={Helpers.translate_options(Posts.list_categories())}
          />
          <.input
            field={@form[:tags]}
            type="text"
            phx-update="ignore"
            id="headlines-tags-container"
            label={gettext("Tags (Example: Games,News)")}
            value={Enum.join(@headlines.tags || [], ", ")}
            placeholder={gettext("Games,News")}
          />
        </div>

        <div class="grid grid-cols-2 gap-5">
          <%= if length(Accounts.list_user_channels(assigns.current_user.id)) == 0 do %>
            <h1 class="text-rose-400 font-bold">
              {gettext("To create news, you need a channel!")}
              <a class="text-sky-600" href="/channels/new">{gettext("Create channel")}</a>
            </h1>
          <% else %>
            <.input
              field={@form[:channel_id]}
              type="select"
              label={gettext("Author")}
              options={
                Enum.map(Accounts.list_user_channels(assigns.current_user.id), &{&1.name, &1.id})
              }
            />
          <% end %>

          <.input field={@form[:header]} type="text" label={gettext("News image URL")} />
        </div>

        <div phx-update="ignore" id="article-content-container">
          <.input
            field={@form[:content]}
            type="textarea"
            label={gettext("Articles text")}
            rows="10"
            class="min-h-[200px] h-[200px] w-full resize-none transition-none"
          />
        </div>

        <:actions>
          <div class="flex place-items-end text-white font-bold w-full space-x-4">
            <div class="flex-1"></div>
            <.button class="bg-green-600" phx-disable-with={gettext("Saving...")}>
              {gettext("Publish")}
            </.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @moduledoc """
  LiveView module for handling headlines updates and validations.
  """

  @impl true
  def update(%{headlines: headlines} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Posts.change_headlines(headlines)) end)}
  end

  @impl true
  def handle_event("validate", %{"headlines" => headlines_params}, socket) do
    changeset = Posts.change_headlines(socket.assigns.headlines, headlines_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"headlines" => headlines_params}, socket) do
    case socket.assigns.action do
      :edit -> save_and_notify(socket, :update, socket.assigns.headlines, headlines_params)
      :new -> save_and_notify(socket, :create, headlines_params)
    end
  end

  defp save_and_notify(socket, action, headlines_or_params, headlines_params \\ nil) do
    save_fn = if action == :update, do: &Posts.update_headlines/2, else: &Posts.create_headlines/1

    args =
      if action == :update,
        do: [headlines_or_params, headlines_params],
        else: [headlines_or_params]

    case apply(save_fn, args) do
      {:ok, headlines} ->
        notify_parent({:saved, headlines})

        {:noreply,
         socket
         |> put_flash(
           :ok,
           Gettext.gettext(RednewsWeb.Gettext, "Headlines #{action}d successfully")
         )
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
