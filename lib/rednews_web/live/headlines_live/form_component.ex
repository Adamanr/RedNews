defmodule RednewsWeb.HeadlinesLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Рассказать о новости
        <:subtitle>Расскажите всем о том, что произошло!</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="headlines-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Заголовок" />
        <.input field={@form[:content]} type="textarea" label="Текст новости" />
        <.input
          field={@form[:category]}
          type="select"
          label="Категория"
          options={Posts.list_categories}
        />
        <.input field={@form[:header]} type="text" label="Картинка новости (URL)" />
        <.input field={@form[:tags]} type="text" label="Тэги (через запятую)" value={Enum.join(@headlines.tags || [], ", ")}  placeholder="Игры, Новости" />

        <:actions>
          <.button phx-disable-with="Saving...">Опубликовать</.button>
        </:actions>
      </.simple_form>
    </div>
    """
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

  @doc """
  Handles the "validate" event for headlines form validation.

  ## Parameters
  - `"headlines"`: A map containing the headlines parameters to validate.

  ## Returns
  - Updates the form in the socket with validation results.
  """
  @impl true
  def handle_event("validate", %{"headlines" => headlines_params}, socket) do
    headlines_params = Map.delete(headlines_params, "tags")
    changeset = Posts.change_headlines(socket.assigns.headlines, headlines_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @doc """
  Handles the "save" event for saving headlines data.

  ## Parameters
  - `"headlines"`: A map containing the headlines parameters to save.

  ## Returns
  - Saves the headlines and notifies the parent process.
  - Redirects or shows validation errors based on the result.
  """
  @impl true
  def handle_event("save", %{"headlines" => headlines_params}, socket) do
    headlines_params = Map.put(headlines_params, "author", 1)

    case socket.assigns.action do
      :edit -> save_and_notify(socket, :update, socket.assigns.headlines, headlines_params)
      :new -> save_and_notify(socket, :create, headlines_params)
    end
  end

  @doc """
  Saves the headlines and notifies the parent process.

  ## Parameters
  - `socket`: The current LiveView socket.
  - `action`: The action to perform (`:update` or `:create`).
  - `headlines_or_params`: Either the existing headlines (for update) or the headlines parameters (for create).

  ## Returns
  - Updates the socket with a success message or validation errors.
  """
  defp save_and_notify(socket, action, headlines_or_params, headlines_params \\ nil) do
    save_fn = if action == :update, do: &Posts.update_headlines/2, else: &Posts.create_headlines/1
    args = if action == :update, do: [headlines_or_params, headlines_params], else: [headlines_or_params]

    case apply(save_fn, args) do
      {:ok, headlines} ->
        notify_parent({:saved, headlines})

        {:noreply,
        socket
        |> put_flash(:info, "Headlines #{action}d successfully")
        |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
