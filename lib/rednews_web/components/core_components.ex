defmodule RednewsWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  use Gettext, backend: RednewsWeb.Gettext

  alias RednewsWeb.Components.TableContent
  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class={@class}
            >
              <div class="absolute text-black top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none text-black p-3 opacity-80 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-2 right-2 mr-2 w-fit z-50"
      {@rest}
    >
      <div class="succsess-alert py-[10px] h-fit cursor-default flex  justify-between w-full h-12 p-4 rounded-lg bg-[#232531] px-[10px]">
        <div class="flex gap-2 p-34">
          <div class="text-[#2b9875] flex items-center gap-2 bg-white/5 backdrop-blur-xl leading-6 p-1 rounded-lg">
            <svg
              :if={@kind == :info}
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-10 h-10"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"></path>
            </svg>
            <svg
              :if={@kind == :error}
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-6 h-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z"
              >
              </path>
            </svg>
          </div>
          <div>
            <p class="text-white">{@title}</p>
            <p class="text-gray-500">{msg}</p>
          </div>
        </div>
        <button
          type="button"
          aria-label={gettext("close")}
          class="text-gray-600 text-gray-600 hover:bg-white/5 p-1 rounded-md transition-colors ease-linear"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-6 h-6"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    </div>
    """
  end

  def flash_create_headline(assigns) do
    ~H"""
    <div class="brutalist-card">
      <div class="brutalist-card__header">
        <div class="brutalist-card__icon">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z">
            </path>
          </svg>
        </div>
        <div class="brutalist-card__alert">Warning</div>
      </div>
      <div class="brutalist-card__message">
        This is a brutalist card with a very angry button. Proceed with caution,
        you've been warned.
      </div>
      <div class="brutalist-card__actions">
        <a class="brutalist-card__button brutalist-card__button--mark" href="#">Mark as Read</a>
        <a class="brutalist-card__button brutalist-card__button--read" href="#">Okay</a>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 ">
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  alias Rednews.Posts

  attr :class, :string, default: nil

  def category(assigns) do
    ~H"""
    <div class={"w-full grid grid-cols-5 gap-5 flex-wrap #{@class}"}>
      <%= for {item, value} <- Posts.list_layout_categories do %>
        <div class="dark:bg-gray-800 bg-white dark:text-gray-400 rounded-lg w-full flex items-center justify-center p-4 text-black">
          <div class="flex items-center space-x-4">
            <img class="w-8 h-8" src={"/images/#{value.name}.svg"} />
            <p class="text-xl">{item}</p>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg py-2 px-3",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 bg-gray-400 text-zinc-900 focus:ring-0"
          {@rest}
        />
        {@label}
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block border-0 bg-gray-100 w-full rounded-md  shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full border-0 bg-gray-100 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div>
      <.label for={@id}>{@label}</.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full border-0 bg-gray-100 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Menu components
  """
  attr :current_path, :any, required: false
  attr :current_user, :any, required: true

  def menu(assigns) do
    ~H"""
      <div class="h-20 flex bg-white font-[Marmelad:Regular]">
        <.link href="/" class="flex w-[11.5vw] md:text-3xl md:flex hidden md:block font-black px-6 px-2 h-full items-center space-x-3">RedNews</.link>
        <div class="flex-1 px-6 md:text-xl text-md flex h-full items-center gap-6">
          <div class="h-full">
            <.link href="/news" class={"flex px-2 h-full  items-center space-x-3 #{if @current_path == "/news", do: "border-b-2 border-gray-800", else: "bg-white"}"}>
              <img class="h-5 w-5 text-black" src={"/images/news.svg"}>
              <h1 class="">Новости</h1>
            </.link>
          </div>
          <.link href="/articles" class={"flex px-2 h-full  items-center space-x-3 #{if @current_path == "/articles", do: "border-b-2 border-gray-800", else: "bg-white"}"}>
            <div class="flex px-2  h-full items-center space-x-3">
              <img class="h-5 w-5 text-black" src={"/images/articles.svg"}>
              <h1 class="">Статьи</h1>
            </div>
          </.link>
          <.link href="/channels" class={"flex px-2 h-full  items-center space-x-3 #{if @current_path == "/channels", do: "border-b-2 border-gray-800", else: "bg-white"}"}>
            <div class="flex px-2  h-full items-center space-x-3">
              <img class="h-5 w-5 text-black" src={"/images/channels.svg"}>
              <h1 class="">Каналы</h1>
            </div>
          </.link>
        </div>

        <%= if not is_nil(@current_user) do %>
          <.link href={"/users/user/#{@current_user.id}"}>
            <div class="flex px-2  h-full items-center">
              <img src={@current_user.avatar} class="items-center rounded-md h-10 w-10 ">
            </div>
          </.link>
        <% end %>

        <button
            type="button"
            id="openModalButton"
            class="me-5 ms-2"
          >
            <img src={"/images/add.svg"} class="h-11 w-11 text-black">
        </button>

        <div
          class="fixed antialiased inset-0 bg-stone-800 bg-opacity-75 flex justify-center items-center opacity-0 pointer-events-none transition-opacity duration-300 ease-out z-[9999]"
          id="exampleModalWeb3"
          aria-hidden="true"
        >
          <div class="bg-white rounded-lg w-9/12 sm:w-7/12 md:w-5/12 lg:w-3/12 scale-95 transition-transform duration-300 ease-out">
            <div class="border-b border-stone-200 p-4 flex justify-between items-start">
              <div class="flex flex-col">
                <h1 class="text-lg text-stone-800 font-semibold">Создать</h1>
                <p class="font-sans text-base text-stone-500">Выберите что хотите создать</p>
              </div>
              <button
                type="button"
                id="closeModalButton"
                aria-label="Close"
                class="text-stone-500 hover:text-stone-800"
              >
                &times;
              </button>
            </div>

            <div class="p-4 text-stone-500">
              <p class="font-sans text-base text-stone-800 dark:text-white mb-2 font-semibold">Посты</p>
              <div class="space-y-10 ">
                <.link href="/news/new" class="mb-5">
                  <button class="inline-flex space-x-4 w-full gap-2 items-center justify-center border align-middle select-none font-sans font-medium text-center duration-300 ease-in disabled:opacity-50 disabled:shadow-none disabled:cursor-not-allowed focus:shadow-none text-sm py-2 px-4 shadow-sm hover:shadow-md bg-stone-200 hover:bg-stone-100 relative bg-gradient-to-b from-white to-white border-stone-200 text-stone-700 rounded-lg hover:bg-gradient-to-b hover:from-stone-50 hover:to-stone-50 hover:border-stone-200 after:absolute after:inset-0 after:rounded-[inherit] after:box-shadow after:shadow-[inset_0_1px_0px_rgba(255,255,255,0.35),inset_0_-1px_0px_rgba(0,0,0,0.20)] after:pointer-events-none transition">
                    <img alt="metamask" src={"/images/news.svg"} class="h-5 w-5">
                    <p class="font-sans text-base text-inherit font-semibold">Создать новость</p>
                  </button>
                </.link>
                <br>
                <.link href="/articles/new" class="mt-4">
                  <button class="inline-flex mt-3 space-x-4 w-full gap-2 items-center justify-center border align-middle select-none font-sans font-medium text-center duration-300 ease-in disabled:opacity-50 disabled:shadow-none disabled:cursor-not-allowed focus:shadow-none text-sm py-2 px-4 shadow-sm hover:shadow-md bg-stone-200 hover:bg-stone-100 relative bg-gradient-to-b from-white to-white border-stone-200 text-stone-700 rounded-lg hover:bg-gradient-to-b hover:from-stone-50 hover:to-stone-50 hover:border-stone-200 after:absolute after:inset-0 after:rounded-[inherit] after:box-shadow after:shadow-[inset_0_1px_0px_rgba(255,255,255,0.35),inset_0_-1px_0px_rgba(0,0,0,0.20)] after:pointer-events-none transition">
                    <img alt="coinbase" src={"/images/articles.svg"} class="h-6 w-6 rounded">
                    <p class="font-sans text-base text-inherit font-semibold">Создать статью</p>
                  </button>
                </.link>
              </div>
              <p class="font-sans text-base text-stone-800 dark:text-white mb-2 mt-6 font-semibold">Каналы</p>
              <.link href="/channels/new">
                <button class="inline-flex space-x-4  w-full gap-2 items-center justify-center border align-middle select-none font-sans font-medium text-center duration-300 ease-in disabled:opacity-50 disabled:shadow-none disabled:cursor-not-allowed focus:shadow-none text-sm py-2 px-4 shadow-sm hover:shadow-md bg-stone-200 hover:bg-stone-100 relative bg-gradient-to-b from-white to-white border-stone-200 text-stone-700 rounded-lg hover:bg-gradient-to-b hover:from-stone-50 hover:to-stone-50 hover:border-stone-200 after:absolute after:inset-0 after:rounded-[inherit] after:box-shadow after:shadow-[inset_0_1px_0px_rgba(255,255,255,0.35),inset_0_-1px_0px_rgba(0,0,0,0.20)] after:pointer-events-none transition">
                  <img alt="trustwallet" src={"/images/channels.svg"} class=" h-6 w-6 rounded">
                  <p class="font-sans text-base text-inherit font-semibold">Создать канал</p>
                </button>
              </.link>
            </div>

            <div class="border-t border-stone-200 p-4 flex flex-col items-center gap-2">
              <small class="font-sans antialiased text-sm text-stone-800 text-center">
                Нет того, что вы хотите сделать?
              </small>
              <.link href="https://github.com/Adamanr/RedNews/issues">
                <button class="inline-flex gap-2 items-center justify-center border align-middle select-none font-sans font-medium text-center duration-300 ease-in disabled:opacity-50 disabled:shadow-none disabled:cursor-not-allowed focus:shadow-none text-sm py-2 px-4 shadow-sm hover:shadow-md bg-stone-200 hover:bg-stone-100 relative bg-gradient-to-b from-white to-white border-stone-200 text-stone-700 rounded-lg hover:bg-gradient-to-b hover:from-stone-50 hover:to-stone-50 hover:border-stone-200 after:absolute after:inset-0 after:rounded-[inherit] after:box-shadow after:shadow-[inset_0_1px_0px_rgba(255,255,255,0.35),inset_0_-1px_0px_rgba(0,0,0,0.20)] after:pointer-events-none transition">
                Проверьте, есть ли это в issue GitHub проекта =)
                </button>
              </.link>
            </div>
          </div>
        </div>

        <script>
          const modal = document.getElementById("exampleModalWeb3");
          const openModalButton = document.getElementById("openModalButton");
          const closeModalButton = document.getElementById("closeModalButton");

          openModalButton.addEventListener("click", () => {
            modal.classList.remove("opacity-0", "pointer-events-none");
            modal.classList.add("opacity-100");
          });

          closeModalButton.addEventListener("click", () => {
            modal.classList.add("opacity-0", "pointer-events-none");
            modal.classList.remove("opacity-100");
          });
        </script>
      </div>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end


  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">{col[:label]}</th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  {render_slot(col, @row_item.(row))}
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  {render_slot(action, @row_item.(row))}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders the sidebar component.

  ## Attributes
  - `current_user`: The current user's data. Required to display user-specific options like profile and logout.

  ## Examples
      <.sidebar current_user={@current_user} />
  """

  attr :current_path, :any, required: false
  attr :categories, :list, default: []
  attr :selected_category, :string, default: nil
  attr :selected_date, :string, default: nil

  def sidebar(assigns) do
    ~H"""
    <div class="w-[12vw] mb-20 h-full flex flex-col space-y-8 pe-4 py-2 z-30">
      <div class="p-5 rounded-xl bg-white ">
        <h1 class="font-bold">Дата</h1>
        <ul class="mt-4 text-gray-600 space-y-2">
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "all"})}
            class={"#{if @selected_date == "all", do: "underline underline-offset-4"}"}
          >
            Все
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "today"})}
            class={"#{if @selected_date == "today", do: "underline underline-offset-4"}"}
          >
            За сегодня
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "week"})}
            class={"#{if @selected_date == "week", do: "underline underline-offset-4"}"}
          >
            За неделю
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "month"})}
            class={"#{if @selected_date == "month", do: "underline underline-offset-4"}"}
          >
            За месяц
          </li>
        </ul>
      </div>
      <div class="p-5 rounded-xl  bg-white ">
        <h1 class="font-bold">Лента</h1>
        <ul class="mt-4  space-y-2">
          <li
            class="text-gray-600 cursor-pointer hover:text-gray-800"
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{options: "category", params: nil })}
          >
            Все
          </li>
          <%= for {item, value} <- Posts.list_layout_categories do %>
            <li
                class={
                      "text-gray-600 cursor-pointer hover:text-gray-800 " <>
                      if(value == @selected_category, do: "underline underline-offset-4", else: "")
                    }
                phx-click="filtred"
                phx-value-filter={Jason.encode!(%{options: "category", params: item})}
              >
                <%= item  %>
              </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500">{item.title}</dt>
          <dd class="text-zinc-700">{render_slot(item)}</dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="">
      <.link
        navigate={@navigate}
        class="text-xl font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-6 w-6 mb-1" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(RednewsWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(RednewsWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
