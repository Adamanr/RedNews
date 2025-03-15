defmodule RednewsWeb.CommentsLive.FormComponent do
  use RednewsWeb, :live_component

  alias Rednews.Posts
  alias Rednews.Accounts
  alias RednewsWeb.Helpers

  def render(assigns) do
    ~H"""
    <div class="comments-section ">
      <div class="relative ">
        <h3 class="text-2xl font-bold text-gray-900 mb-6">Комментарии</h3>
        <%= if not is_nil(@current_user) do %>
          <.form for={@form} id="comment-form" phx-target={@myself} phx-submit="create_comment">
              <.input
                field={@form[:content]}
                type="textarea"
                placeholder="Оставьте свой комментарий..."
                class="w-full p-4 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition duration-200 resize-none min-h-[120px]"
                required
              />

            <div class="text-right mt-2 mb-4">
              <.button
                phx-disable-with="Отправка..."
                class="bg-indigo-600 hover:bg-indigo-700 px-3 py-3 rounded-xl text-white font-semibold transition duration-200 flex items-center gap-2"
              >
                <svg class="w-4 h-4 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                  />
                </svg>
                Отправить
              </.button>
            </div>
          </.form>
        <% end %>


        <%= if @reply && @reply != %{} do %>
          <div class="my-6 bg-indigo-50 rounded-xl p-4 border border-indigo-100">
            <div class="flex items-center gap-4">
              <div class="bg-indigo-100 rounded-full p-2">
                <svg class="w-6 h-6 text-indigo-600" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M4.5 12L9.5 7M4.5 12L9.5 17M4.5 12L11 12M14.5 12C16.1667 12 19.5 13 19.5 17"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  />
                </svg>
              </div>
              <div class="flex-1">
                <p class="font-semibold text-gray-900">
                  {Accounts.get_user!(@reply.author).username}
                </p>
                <p class="text-gray-600 mt-1">{@reply.content}</p>
              </div>
              <.button
                phx-click="remove_reply"
                phx-target={@myself}
                class="text-gray-500 hover:text-gray-700"
              >
                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none">
                  <path
                    d="M14.5 9.50002L9.5 14.5M9.49998 9.5L14.5 14.5"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                  />
                </svg>
              </.button>
            </div>
          </div>
        <% end %>

        <%= if length(@comments) == 0 do%>
            <h1 class="text-xl text-gray-500">Тут пока пусто</h1>
        <% else %>
          <div id="comments-list" class="space-y-4">
            <%= for item <- @comments, is_nil(item.comment.reply_id) do %>
              <div id={"comment-#{item.comment.id}"} class="">
                <div class="flex items-start gap-4 bg-white p-2 rounded-lg">
                  <img
                    src={item.author.avatar || "/images/default-avatar.png"}
                    class="w-12 h-12 rounded-full object-cover border-2 border-white shadow-sm"
                    alt={item.author.username}
                  />
                  <div class="flex-1">
                    <div class="flex items-center justify-between">
                      <div>
                        <h4 class="font-semibold text-gray-900">{item.author.username}</h4>
                        <p class="text-sm text-gray-500 mt-1">
                          {Calendar.strftime(item.comment.inserted_at, "%B %d, %Y at %I:%M %p")}
                        </p>
                      </div>
                      <%= if @current_user && @current_user.id == item.comment.author do %>
                        <div class="flex gap-2">
                          <.button
                            phx-click="reply_comment"
                            phx-value-id={item.comment.id}
                            phx-target={@myself}
                            class="text-sm bg-indigo-100 text-indigo-700 hover:bg-indigo-400 rounded-lg transition duration-200"
                          >
                            <svg class="w-6 h-6 text-white" viewBox="0 0 24 24" fill="none">
                              <path
                                d="M4.5 12L9.5 7M4.5 12L9.5 17M4.5 12L11 12M14.5 12C16.1667 12 19.5 13 19.5 17"
                                stroke="currentColor"
                                stroke-width="2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                              />
                            </svg>
                          </.button>
                          <.button
                            phx-click="delete_comment"
                            phx-value-id={item.comment.id}
                            phx-target={@myself}
                            class="text-sm bg-red-100 text-red-700 hover:bg-red-400 rounded-lg transition duration-200"
                            data-confirm="Вы уверены, что хотите удалить этот комментарий?"
                          >
                            <svg
                              class="w-5 h-5 text-white"
                              viewBox="0 0 24 24"
                              fill="none"
                              xmlns="http://www.w3.org/2000/svg"
                            >
                              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                              <g
                                id="SVGRepo_tracerCarrier"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                              >
                              </g>
                              <g id="SVGRepo_iconCarrier">
                                <path
                                  d="M14.5 9.50002L9.5 14.5M9.49998 9.5L14.5 14.5"
                                  stroke="currentColor"
                                  stroke-width="1.5"
                                  stroke-linecap="round"
                                >
                                </path>

                                <path
                                  d="M7 3.33782C8.47087 2.48697 10.1786 2 12 2C17.5228 2 22 6.47715 22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 10.1786 2.48697 8.47087 3.33782 7"
                                  stroke="currentColor"
                                  stroke-width="1.5"
                                  stroke-linecap="round"
                                >
                                </path>
                              </g>
                            </svg>
                          </.button>
                        </div>
                      <% end %>
                    </div>
                    <div class="mt-3 text-gray-700 prose prose-sm max-w-none">
                      {raw(Helpers.to_html(item.comment.content))}
                    </div>
                  </div>
                </div>
                <div class="border-black border-l-2 ms-3">
                  <%= for reply_item <- Posts.get_reply_comments(assigns.pub_id, assigns.pub_type, item.comment.id) do %>
                    <div id={"comment-#{reply_item.comment.id}"} class="mt-4 ml-4 bg-gray-300  p-2">
                      <div class="flex items-start gap-4">
                        <img
                          src={reply_item.author.avatar || "/images/default-avatar.png"}
                          class="w-10 h-10 rounded-full object-cover border-2 border-gray-100"
                          alt={reply_item.author.username}
                        />
                        <div class="flex-1">
                          <div class="flex items-center justify-between">
                            <div>
                              <h4 class="font-semibold text-gray-900">
                                {reply_item.author.username}
                              </h4>
                              <p class="text-sm text-gray-500 mt-1">
                                {Calendar.strftime(
                                  reply_item.comment.inserted_at,
                                  "%B %d, %Y at %I:%M %p"
                                )}
                              </p>
                            </div>
                            <%= if @current_user && @current_user.id == reply_item.comment.author do %>
                              <div class="flex gap-2">
                                <.button
                                  phx-click="delete_comment"
                                  phx-value-id={reply_item.comment.id}
                                  phx-target={@myself}
                                  class="text-xs px-3 py-1.5 bg-red-100 text-red-700 hover:bg-red-400 rounded-lg transition duration-200"
                                  data-confirm="Вы уверены, что хотите удалить этот комментарий?"
                                >
                                  <svg
                                    class="w-5 h-5 text-white"
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    xmlns="http://www.w3.org/2000/svg"
                                  >
                                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                                    <g
                                      id="SVGRepo_tracerCarrier"
                                      stroke-linecap="round"
                                      stroke-linejoin="round"
                                    >
                                    </g>
                                    <g id="SVGRepo_iconCarrier">
                                      <path
                                        d="M14.5 9.50002L9.5 14.5M9.49998 9.5L14.5 14.5"
                                        stroke="currentColor"
                                        stroke-width="1.5"
                                        stroke-linecap="round"
                                      >
                                      </path>

                                      <path
                                        d="M7 3.33782C8.47087 2.48697 10.1786 2 12 2C17.5228 2 22 6.47715 22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12C2 10.1786 2.48697 8.47087 3.33782 7"
                                        stroke="currentColor"
                                        stroke-width="1.5"
                                        stroke-linecap="round"
                                      >
                                      </path>
                                    </g>
                                  </svg>
                                </.button>
                              </div>
                            <% end %>
                          </div>
                          <div class="mt-3 text-gray-700 prose prose-sm max-w-none">
                            {raw(Helpers.to_html(reply_item.comment.content))}
                          </div>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(%{"content" => ""}))
     |> assign(:reply, %{})
     |> assign(:comments, Posts.get_comments(assigns.pub_id, assigns.pub_type))}
  end

  def handle_event("create_comment", %{"content" => content}, socket) do
    comment_params = %{
      "content" => content,
      "pub_type" => socket.assigns.pub_type,
      "pub_id" => socket.assigns.pub_id,
      "author" => socket.assigns.current_user.id,
      "reply_id" => Map.get(socket.assigns, :reply, %{}) |> Map.get(:id)
    }

    case Posts.create_comment(comment_params) do
      {:ok, _comment} ->
        {:noreply,
         socket
         |> assign(:comments, Posts.get_comments(socket.assigns.pub_id, socket.assigns.pub_type))
         |> put_flash(:info, "Comment added successfully!")
         |> assign(:form, to_form(%{"content" => ""}))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating comment: #{error_to_string(changeset)}")
         |> assign(:form, to_form(changeset))}
    end
  end

  def handle_event("reply_comment", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)
    {:noreply, socket |> assign(:reply, Posts.get_comment(id, socket.assigns.pub_type))}
  end

  def handle_event("remove_reply", _params, socket) do
    {:noreply, socket |> assign(:reply, %{})}
  end

  def handle_event("delete_comment", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)

    case Posts.delete_comment(id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Comment deleted successfully!")
         |> assign(:comments, Posts.get_comments(socket.assigns.pub_id, socket.assigns.pub_type))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error deleting comment")}
    end
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k} #{v}" end)
    |> Enum.join(", ")
  end
end
