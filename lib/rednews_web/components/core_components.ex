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
      <div
        id={"#{@id}-bg"}
        class="bg-zinc-50/90 dark:bg-gray-800/80 fixed inset-0 transition-opacity"
        aria-hidden="true"
      />
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
                  <.icon name="hero-x-mark-solid dark:text-white" class="h-5 w-5" />
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

  def tabs(assigns) do
    ~H"""
    <div class="tabs">
      <div class="flex border-b">
        <%= for {tab, idx} <- Enum.with_index(@tabs) do %>
          <button
            class={"px-4 py-2 font-medium #{if @active_tab == idx, do: "border-b-2 border-blue-500 text-blue-600", else: "text-gray-500 hover:text-gray-700"}"}
            phx-click="switch_tab"
            phx-value-tab={idx}
          >
            {tab}
          </button>
        <% end %>
      </div>
      <div class="tab-content py-4">
        {render_slot(@tab_content, @active_tab)}
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
      <div class="space-y-8 ">
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
      <%= for value <- Posts.list_categories do %>
        <div class="dark:bg-gray-800 bg-white dark:text-gray-400 rounded-lg w-full flex items-center justify-center p-4 text-black">
          <div class="flex items-center space-x-4">
            <img class="w-8 h-8" src={"/images/#{value.name}.svg"} />
            <p class="text-xl">{value}</p>
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
          class="rounded dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200 border-zinc-300 bg-gray-400 text-zinc-900 focus:ring-0"
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
        class="mt-2 block dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200 border-2 border-zinc-300 focus:border-zinc-400 w-full rounded-md  shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
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
          "mt-2 block w-full dark:bg-gray-700 dark:border-gray-600 dark:text-gray-300 border-2 bg-gray-100 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
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
          "mt-2 block w-full dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200 border-2 dark:text-gray-300 bg-gray-100 rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
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
    <label for={@for} class="block dark:text-gray-300 text-sm font-semibold leading-6 text-zinc-800">
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

  attr :class, :string, default: nil
  attr :theme, :string, default: "sytem"
  attr :locale, :string, default: "en"

  def settings_modal(assigns) do
    ~H"""
    <button
      type="button"
      id="openSettingsModal"
      class={"#{@class} group relative"}
      aria-label={gettext("Open settings")}
    >
      <div class="absolute inset-0 bg-indigo-500 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-md">
      </div>
      <div class="relative flex items-center justify-center h-12 w-12 bg-white dark:bg-gray-800 rounded-full shadow-lg hover:shadow-xl transition-all duration-300 group-hover:bg-indigo-600 group-hover:scale-110">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6 text-gray-600 group-hover:text-white transition-colors"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
          />
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
          />
        </svg>
      </div>
    </button>

    <div
      class="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex justify-center items-center opacity-0 pointer-events-none transition-all duration-300 z-[9999]"
      id="settingsModal"
      aria-hidden="true"
      phx-hook="Modal"
    >
      <div class="bg-white dark:bg-gray-900 rounded-2xl w-11/12 sm:w-4/5 md:w-2/3 lg:w-1/3 max-h-[90vh] overflow-y-auto transform scale-95 transition-transform duration-300 shadow-xl">
        <div class="sticky top-0 z-10 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 p-5 flex justify-between items-center rounded-t-2xl">
          <div class="flex items-center space-x-3">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6 text-indigo-500"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
              />
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
              />
            </svg>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">{gettext("Settings")}</h2>
          </div>
          <button
            type="button"
            id="closeSettingsModal"
            aria-label={gettext("Close")}
            class="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>

        <div class="p-5 space-y-6">
          <div class="space-y-3">
            <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 flex items-center space-x-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-indigo-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                />
              </svg>
              <span>{gettext("Appearance")}</span>
            </h3>
            <div class="grid grid-cols-3 gap-3">
              <button
                data-theme-value="light"
                class={"flex flex-col items-center p-3 rounded-xl border-2 transition-all #{if @theme == "light", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300"}"}
              >
                <div class="w-full h-16 mb-2 bg-white rounded-lg shadow-inner overflow-hidden">
                  <div class="h-full flex">
                    <div class="w-1/4 bg-gray-100"></div>
                    <div class="w-3/4 bg-white"></div>
                  </div>
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  {gettext("Light")}
                </span>
              </button>

              <button
                data-theme-value="dark"
                class={"flex flex-col items-center p-3 rounded-xl border-2 transition-all #{if @theme == "dark", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300"}"}
              >
                <div class="w-full h-16 mb-2 bg-gray-900 rounded-lg shadow-inner overflow-hidden">
                  <div class="h-full flex">
                    <div class="w-1/4 bg-gray-800"></div>
                    <div class="w-3/4 bg-gray-900"></div>
                  </div>
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  {gettext("Dark")}
                </span>
              </button>

              <button
                data-theme-value="system"
                class={"flex flex-col items-center p-3 rounded-xl border-2 transition-all #{if @theme == "system", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300"}"}
              >
                <div class="w-full h-16 mb-2 bg-gradient-to-r from-white to-gray-900 rounded-lg shadow-inner overflow-hidden">
                  <div class="h-full flex">
                    <div class="w-1/4 bg-gradient-to-b from-gray-100 to-gray-800"></div>
                    <div class="w-3/4 bg-gradient-to-b from-white to-gray-900"></div>
                  </div>
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  {gettext("System")}
                </span>
              </button>
            </div>
          </div>

          <div class="space-y-3">
            <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 flex items-center space-x-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-indigo-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129"
                />
              </svg>
              <span>{gettext("Language")}</span>
            </h3>
            <div class="grid grid-cols-2 gap-4 w sm:grid-cols-4 gap-1">
              <.link href="/change_locale/ja" class="flag-icon hover:scale-110 transition-transform">
                <button class={"flex w-full items-center justify-center p-3 rounded-lg border transition-all #{if assigns.locale == "ja", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 font-medium", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300 text-gray-700 dark:text-gray-300"}"}>
                  <span class="mr-2">🇯🇵</span> 日本語
                </button>
              </.link>

              <.link href="/change_locale/zh" class="flag-icon hover:scale-110 transition-transform">
                <button class={"flex w-full items-center justify-center p-3 rounded-lg border transition-all #{if assigns.locale == "zh", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 font-medium", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300 text-gray-700 dark:text-gray-300"}"}>
                  <span class="mr-2">🇨🇳</span> 中文
                </button>
              </.link>

              <.link href="/change_locale/en" class="flag-icon hover:scale-110 transition-transform">
                <button class={"flex w-full items-center justify-center p-3 rounded-lg border transition-all #{if assigns.locale == "en", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 font-medium", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300 text-gray-700 dark:text-gray-300"}"}>
                  <span class="mr-2">🇬🇧</span> English
                </button>
              </.link>

              <.link href="/change_locale/ru" class="flag-icon hover:scale-110 transition-transform">
                <button class={"flex w-full items-center justify-center p-3 rounded-lg border transition-all #{if assigns.locale == "ru", do: "border-indigo-500 bg-indigo-50 dark:bg-gray-800 text-indigo-600 dark:text-indigo-400 font-medium", else: "border-gray-200 dark:border-gray-700 hover:border-indigo-300 text-gray-700 dark:text-gray-300"}"}>
                  <span class="mr-2">🇷🇺</span> Русский
                </button>
              </.link>
            </div>
          </div>

          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 flex items-center space-x-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-indigo-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
              <span>{gettext("Preferences")}</span>
            </h3>

            <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="flex items-center space-x-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 text-gray-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                  />
                </svg>
                <div>
                  <p class="font-medium text-gray-700 dark:text-gray-300">
                    {gettext("Notifications")}
                  </p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Enable app notifications")}
                  </p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" class="sr-only peer" />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-indigo-300 dark:peer-focus:ring-indigo-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-indigo-600">
                </div>
              </label>
            </div>

            <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="flex items-center space-x-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 text-gray-500"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
                <div>
                  <p class="font-medium text-gray-700 dark:text-gray-300">
                    {gettext("Email Digest")}
                  </p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Weekly newsletter")}
                  </p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" checked class="sr-only peer" />
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-indigo-300 dark:peer-focus:ring-indigo-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-indigo-600">
                </div>
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <script>
      document.getElementById("openSettingsModal").addEventListener("click", function() {
        const modal = document.getElementById("settingsModal");
        modal.classList.remove("opacity-0", "pointer-events-none");
        modal.classList.add("opacity-100");
      });

      document.getElementById("closeSettingsModal").addEventListener("click", function() {
        const modal = document.getElementById("settingsModal");
        modal.classList.add("opacity-0", "pointer-events-none");
        modal.classList.remove("opacity-100");
        document.body.style.overflow = '';
      });

      document.getElementById("settingsModal").addEventListener("click", function(e) {
        if (e.target === this) {
          this.classList.add("opacity-0", "pointer-events-none");
          this.classList.remove("opacity-100");
          document.body.style.overflow = '';
        }
      });

      function applyTheme(theme) {
        document.documentElement.classList.remove("light", "dark");

        localStorage.setItem("theme", theme);

        if (theme === "system") {
          const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
          document.documentElement.classList.add(prefersDark ? "dark" : "light");
        } else {
          document.documentElement.classList.add(theme);
        }

        document.documentElement.setAttribute("data-theme", theme);

        document.querySelectorAll("[data-theme-value]").forEach(button => {
          if (button.getAttribute("data-theme-value") === theme) {
            button.classList.add("border-indigo-500", "bg-indigo-50", "dark:bg-gray-800");
            button.classList.remove("border-gray-200", "dark:border-gray-700", "hover:border-indigo-300");
          } else {
            button.classList.remove("border-indigo-500", "bg-indigo-50", "dark:bg-gray-800");
            button.classList.add("border-gray-200", "dark:border-gray-700", "hover:border-indigo-300");
          }
        });
      }

      document.querySelectorAll("[data-theme-value]").forEach(button => {
        button.addEventListener("click", function() {
          const theme = this.getAttribute("data-theme-value");
          applyTheme(theme);
        });
      });

      document.addEventListener("DOMContentLoaded", function() {
        const savedTheme = localStorage.getItem("theme") || "system";
        applyTheme(savedTheme);

        window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function() {
          const currentTheme = localStorage.getItem("theme") || "system";
          if (currentTheme === "system") {
            applyTheme("system");
          }
        });
      });
    </script>
    """
  end

  attr :class, :string, default: nil

  def create_modal(assigns) do
    ~H"""
    <button
      type="button"
      id="openCreateModal"
      class={"#{@class} group relative"}
      aria-label={gettext("Create new content")}
    >
      <div class="absolute inset-0 bg-indigo-500 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-md">
      </div>
      <div class="relative flex items-center justify-center h-12 w-12 bg-white dark:bg-gray-800 rounded-full shadow-lg hover:shadow-xl transition-all duration-300 group-hover:bg-indigo-600 group-hover:scale-110">
        <svg
          class="h-6 w-6 text-gray-600 group-hover:text-white transition-colors"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
          />
        </svg>
      </div>
    </button>

    <div
      class="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex justify-center items-center opacity-0 pointer-events-none transition-all duration-300 z-[9999]"
      id="createModal"
      aria-hidden="true"
      phx-hook="Modal"
    >
      <div class="bg-white dark:bg-gray-900 rounded-2xl w-1/3 max-h-[90vh] overflow-y-auto transform scale-95 transition-transform duration-300 shadow-xl border border-gray-200 dark:border-gray-700">
        <div class="sticky top-0 z-10 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 p-5 flex justify-between items-center rounded-t-2xl">
          <div class="flex items-center space-x-3">
            <svg class="h-6 w-6 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 6v6m0 0v6m0-6h6m-6 0H6"
              />
            </svg>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">{gettext("Create New")}</h2>
          </div>
          <button
            type="button"
            id="closeCreateModal"
            aria-label={gettext("Close")}
            class="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>

        <div class="p-5 space-y-6">
          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 flex items-center space-x-2">
              <svg
                class="h-5 w-5 text-indigo-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"
                />
              </svg>
              <span>{gettext("Publications")}</span>
            </h3>

            <.link navigate="/news/new" class="block">
              <div class="group flex items-center space-x-4 p-4 rounded-xl bg-gray-50 dark:bg-gray-800 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 transition-colors duration-300 border border-gray-200 dark:border-gray-700 hover:border-indigo-300 dark:hover:border-indigo-500">
                <div class="flex-shrink-0 p-3 rounded-lg bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-300 group-hover:bg-indigo-200 dark:group-hover:bg-indigo-800 transition-colors">
                  <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"
                    />
                  </svg>
                </div>
                <div>
                  <h4 class="font-medium text-gray-800 dark:text-gray-200 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                    {gettext("News Post")}
                  </h4>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Share latest updates and announcements")}
                  </p>
                </div>
                <svg
                  class="ml-auto h-5 w-5 text-gray-400 group-hover:text-indigo-500 transition-colors"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </div>
            </.link>

            <.link navigate="/articles/new" class="block">
              <div class="group flex items-center space-x-4 p-4 rounded-xl bg-gray-50 dark:bg-gray-800 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 transition-colors duration-300 border border-gray-200 dark:border-gray-700 hover:border-indigo-300 dark:hover:border-indigo-500">
                <div class="flex-shrink-0 p-3 rounded-lg bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-300 group-hover:bg-indigo-200 dark:group-hover:bg-indigo-800 transition-colors">
                  <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"
                    />
                  </svg>
                </div>
                <div>
                  <h4 class="font-medium text-gray-800 dark:text-gray-200 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                    {gettext("Article")}
                  </h4>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Write in-depth content and stories")}
                  </p>
                </div>
                <svg
                  class="ml-auto h-5 w-5 text-gray-400 group-hover:text-indigo-500 transition-colors"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </div>
            </.link>
          </div>

          <div class="space-y-4">
            <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 flex items-center space-x-2">
              <svg
                class="h-5 w-5 text-indigo-500"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
              <span>{gettext("Channels")}</span>
            </h3>

            <.link navigate="/channels/new" class="block">
              <div class="group flex items-center space-x-4 p-4 rounded-xl bg-gray-50 dark:bg-gray-800 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 transition-colors duration-300 border border-gray-200 dark:border-gray-700 hover:border-indigo-300 dark:hover:border-indigo-500">
                <div class="flex-shrink-0 p-3 rounded-lg bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-300 group-hover:bg-indigo-200 dark:group-hover:bg-indigo-800 transition-colors">
                  <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                    />
                  </svg>
                </div>
                <div>
                  <h4 class="font-medium text-gray-800 dark:text-gray-200 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                    {gettext("Channel")}
                  </h4>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {gettext("Create community space for discussions and publications")}
                  </p>
                </div>
                <svg
                  class="ml-auto h-5 w-5 text-gray-400 group-hover:text-indigo-500 transition-colors"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </div>
            </.link>
          </div>
        </div>

        <div class="sticky bottom-0 bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 p-4 rounded-b-2xl">
          <div class="text-center">
            <p class="text-sm text-gray-500 dark:text-gray-400 mb-2">
              {gettext("Don't see what you're looking for?")}
            </p>
            <.link
              href="https://github.com/Adamanr/RedNews/issues"
              class="inline-flex items-center text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 transition-colors text-sm font-medium"
              target="_blank"
            >
              {gettext("Suggest a feature")}
              <svg class="ml-1 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                />
              </svg>
            </.link>
          </div>
        </div>
      </div>
    </div>

    <script>
      document.getElementById("openCreateModal").addEventListener("click", function() {
        const modal = document.getElementById("createModal");
        modal.classList.remove("opacity-0", "pointer-events-none");
        modal.classList.add("opacity-100");
        document.body.style.overflow = 'hidden';
      });

      document.getElementById("closeCreateModal").addEventListener("click", function() {
        const modal = document.getElementById("createModal");
        modal.classList.add("opacity-0", "pointer-events-none");
        modal.classList.remove("opacity-100");
        document.body.style.overflow = '';
      });

      document.getElementById("createModal").addEventListener("click", function(e) {
        if (e.target === this) {
          this.classList.add("opacity-0", "pointer-events-none");
          this.classList.remove("opacity-100");
          document.body.style.overflow = '';
        }
      });
    </script>
    """
  end

  @doc """
  Menu components
  """
  attr :current_path, :any, required: false
  attr :locale, :string, required: false
  attr :current_user, :any, required: true

  def menu(assigns) do
    ~H"""
    <div class="menu dark:bg-gray-900 bg-white relative  text-white shadow-md z-40">
      <div class="container overflow-x-scroll md:overflow-x-hidden container mx-auto max-w-[100em] mx-auto flex items-center justify-between py-3 px-4">
        <.link
          href="/"
          class="flex hidden md:block  items-center space-x-2 transform hover:scale-105 transition-transform"
        >
          <div class="text-3xl font-black tracking-tight">
            <span class="bg-clip-text  text-transparent bg-gradient-to-r from-pink-400 to-yellow-400">
              RedNews
            </span>
          </div>
        </.link>

        <nav class="text-black dark:text-gray-400 flex items-center space-x-6">
          <.link
            href="/news"
            class={"nav-item dark:dark-nav-item flex #{if @current_path == "/news", do: "active-nav dark:dark-active-nav", else: ""}"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6 mr-2"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2v10z"
              />
            </svg>
            <span>{gettext("News")}</span>
          </.link>

          <.link
            href="/articles"
            class={"flex nav-item dark:dark-nav-item #{if @current_path == "/articles", do: "active-nav dark:dark-active-nav", else: ""}"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6 mr-2"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
            <span>{gettext("Articles")}</span>
          </.link>

          <.link
            href="/channels"
            class={"flex nav-item dark:dark-nav-item #{if @current_path == "/channels", do: "active-nav dark:dark-active-nav", else: ""}"}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6 mr-2"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <span>{gettext("Channels")}</span>
          </.link>

          <.link
            href="/users/feed"
            class={"flex hidden dark:hidden nav-item dark:dark-nav-item #{if @current_path == "/users/feed", do: "active-nav dark:dark-active-nav", else: ""}"}
          >
            <svg
              class="h-6 w-6 mr-2"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
              <g id="SVGRepo_iconCarrier">
                <path
                  d="M12.552 8C11.9997 8 11.552 8.44772 11.552 9C11.552 9.55228 11.9997 10 12.552 10H16.552C17.1043 10 17.552 9.55228 17.552 9C17.552 8.44772 17.1043 8 16.552 8H12.552Z"
                  fill="currentColor"
                  fill-opacity="0.5"
                >
                </path>

                <path
                  d="M12.552 17C11.9997 17 11.552 17.4477 11.552 18C11.552 18.5523 11.9997 19 12.552 19H16.552C17.1043 19 17.552 18.5523 17.552 18C17.552 17.4477 17.1043 17 16.552 17H12.552Z"
                  fill="currentColor"
                  fill-opacity="0.5"
                >
                </path>

                <path
                  d="M12.552 5C11.9997 5 11.552 5.44772 11.552 6C11.552 6.55228 11.9997 7 12.552 7H20.552C21.1043 7 21.552 6.55228 21.552 6C21.552 5.44772 21.1043 5 20.552 5H12.552Z"
                  fill="currentColor"
                  fill-opacity="0.8"
                >
                </path>

                <path
                  d="M12.552 14C11.9997 14 11.552 14.4477 11.552 15C11.552 15.5523 11.9997 16 12.552 16H20.552C21.1043 16 21.552 15.5523 21.552 15C21.552 14.4477 21.1043 14 20.552 14H12.552Z"
                  fill="currentColor"
                  fill-opacity="0.8"
                >
                </path>

                <path
                  d="M3.448 4.00208C2.89571 4.00208 2.448 4.44979 2.448 5.00208V10.0021C2.448 10.5544 2.89571 11.0021 3.448 11.0021H8.448C9.00028 11.0021 9.448 10.5544 9.448 10.0021V5.00208C9.448 4.44979 9.00028 4.00208 8.448 4.00208H3.448Z"
                  fill="currentColor"
                >
                </path>

                <path
                  d="M3.448 12.9979C2.89571 12.9979 2.448 13.4456 2.448 13.9979V18.9979C2.448 19.5502 2.89571 19.9979 3.448 19.9979H8.448C9.00028 19.9979 9.448 19.5502 9.448 18.9979V13.9979C9.448 13.4456 9.00028 12.9979 8.448 12.9979H3.448Z"
                  fill="currentColor"
                >
                </path>
              </g>
            </svg>

            <span>{gettext("Feed")}</span>
          </.link>
        </nav>

        <div class="flex items-center gap-4">
          <.create_modal />

          <.settings_modal locale={@locale} />

          <div class="user-section">
            <%= if not is_nil(@current_user) do %>
              <.link href={"/users/user/#{@current_user.id}"} class="user-avatar">
                <img
                  src={@current_user.avatar}
                  class="h-12 w-12 rounded-full object-cover border-2 border-white shadow-lg hover:scale-110 transition-transform"
                />
              </.link>
            <% else %>
              <.link href="/users/log_in" class="login-button">
                <button
                  type="button"
                  id="openCreateModal"
                  class="group relative"
                  aria-label={gettext("Create new content")}
                >
                  <div class="absolute inset-0 bg-indigo-500 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-md">
                  </div>
                  <div class="relative flex items-center justify-center h-12 w-12 bg-white dark:bg-gray-800 rounded-full shadow-lg hover:shadow-xl transition-all duration-300 group-hover:bg-indigo-600 group-hover:scale-110">
                    <svg
                      class="h-6 w-6 text-gray-600 group-hover:text-white transition-colors"
                      viewBox="0 0 24 24"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M20 23L12 23C11.4477 23 11 22.5523 11 22C11 21.4477 11.4477 21 12 21L20 21C20.5523 21 21 20.5523 21 20L21 4C21 3.44771 20.5523 3 20 3L12 3C11.4477 3 11 2.55228 11 2C11 1.44772 11.4477 1 12 1L20 0.999999C21.6569 0.999999 23 2.34315 23 4L23 20C23 21.6569 21.6569 23 20 23Z"
                        fill="currentColor"
                      />
                      <path
                        fill-rule="evenodd"
                        clip-rule="evenodd"
                        d="M18.6881 10.6901C19.3396 11.4418 19.3396 12.5581 18.6881 13.3098L14.5114 18.1291C13.2988 19.5282 11 18.6707 11 16.8193L11 15L5 15C3.89543 15 3 14.1046 3 13L3 11C3 9.89541 3.89543 8.99998 5 8.99998L11 8.99998L11 7.18071C11 5.3293 13.2988 4.47176 14.5114 5.87085L18.6881 10.6901ZM16.6091 12.6549C16.9348 12.279 16.9348 11.7209 16.6091 11.345L13 7.18071L13 9.49998C13 10.3284 12.3284 11 11.5 11L5 11L5 13L11.5 13C12.3284 13 13 13.6716 13 14.5L13 16.8193L16.6091 12.6549Z"
                        fill="currentColor"
                      />
                    </svg>
                  </div>
                </button>
              </.link>
            <% end %>
          </div>
        </div>
      </div>
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

  @doc """
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
  attr :selected_category, :string, default: nil
  attr :selected_date, :string, default: nil

  def sidebar(assigns) do
    ~H"""
    <div class="w-[12vw] mb-20 h-full flex flex-col space-y-8 pe-4 z-30">
      <div class="p-5  rounded-xl text-gray-600 dark:text-gray-400  dark:bg-gray-900 bg-white">
        <h1 class="font-bold dark:text-gray-200 hover:text-gray-800 dark:hover:text-gray-200">
          {gettext("Date")}
        </h1>
        <ul class="mt-4 cursor-pointer  space-y-2">
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{options: "date", params: "all"})}
            class={"hover:text-gray-800 dark:hover:text-gray-200 #{if @selected_date == "all", do: "underline underline-offset-4"}"}
          >
            {gettext("All")}
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "today"})}
            class={"hover:text-gray-800 dark:hover:text-gray-200 #{if @selected_date == "today", do: "underline underline-offset-4"}"}
          >
            {gettext("Today")}
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "week"})}
            class={"hover:text-gray-800 dark:hover:text-gray-200 #{if @selected_date == "week", do: "underline underline-offset-4"}"}
          >
            {gettext("Week")}
          </li>
          <li
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{"options" => "date", "params" => "month"})}
            class={"hover:text-gray-800 dark:hover:text-gray-200 #{if @selected_date == "month", do: "underline underline-offset-4"}"}
          >
            {gettext("Month")}
          </li>
        </ul>
      </div>
      <div class="p-5 rounded-xl text-gray-600 dark:text-gray-400  dark:bg-gray-900 bg-white ">
        <h1 class="font-bold dark:text-gray-200">{gettext("Categories")}</h1>
        <ul class="mt-4 space-y-2">
          <li
            class="cursor-pointer hover:text-gray-800 dark:hover:text-gray-200"
            phx-click="filtred"
            phx-value-filter={Jason.encode!(%{options: "category", params: nil})}
          >
            {gettext("All")}
          </li>
          <%= for %{label: label, value: value} <- Posts.list_categories do %>
            <li
              class={
                      "cursor-pointer hover:text-gray-800 dark:hover:text-gray-200 " <>
                      if(value == @selected_category, do: "underline underline-offset-4", else: "")
                    }
              phx-click="filtred"
              phx-value-filter={Jason.encode!(%{options: "category", params: value})}
            >
              {label}
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
        {"transition-all opacity-0 transform ease-in duration-200",
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
