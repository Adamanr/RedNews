defmodule Rednews.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Rednews.Repo

  alias Rednews.Accounts.{User, UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
    Returns an `%Ecto.Changeset{}` for changing the user info

    ## Examples
        iex> change_user_info(user)
        %Ecto.Changeset{data: %User{}}
  """
  def change_user_info(user, attrs \\ %{}) do
    User.user_info_changeset(user, attrs)
  end

  @doc """
    Updates the user info.

    ## Examples

    iex> update_user_info(user, %{username: "John Doe", avatar: "https://example.com/avatar.jpg"})
    {:ok, %User{}}

    iex> update_user_info(user, %{username: "John Doe", avatar: "https://example.com/avatar.jpg", login: "john"})
    {:error, %Ecto.Changeset{}}

  """
  def update_user_info(user, attrs) do
    changeset = User.user_info_changeset(user, attrs)

    Repo.update(changeset)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  alias Rednews.Accounts.Channels
  alias Rednews.Posts.Headlines

  @doc """
  Lists channels based on the provided options and parameters.

  ## Parameters
  - `options`: The filtering option (default is `:default`).
    - `:default`: Fetches all channels.
    - `:category`: Filters channels by a specific category.
    - `:date`: Filters channels by date.
    - `:tags`: Filters channels by specific tags.
  - `params`: A map of parameters for filtering (e.g., `%{category: "tech", tags: ["elixir"]}`).

  ## Returns
  - A list of `Channels` matching the specified criteria.

  ## Raises
  - `ArgumentError` if an unknown option is provided.
  """
  def list_channels(options \\ :default, params \\ %{}) do
    query =
      case options do
        :default ->
          from(c in Channels)

        :category ->
          from(c in Channels, where: c.category == ^params[:category])

        :tags ->
          from(c in Channels, where: ^params[:tags] in c.tags)

        :author ->
          if Map.has_key?(params, :user_ids) do
            from(c in Channels, where: c.user_id in ^params[:user_ids])
          else
            from(c in Channels, where: c.user_id == ^params[:user_id])
          end

        :date ->
          case params[:date] do
            "today" ->
              from(c in Channels, where: fragment("?::date = CURRENT_DATE", c.inserted_at))

            "week" ->
              from(c in Channels,
                where: fragment("? >= CURRENT_DATE - INTERVAL '7 days'", c.inserted_at)
              )

            "month" ->
              from(c in Channels,
                where: fragment("? >= CURRENT_DATE - INTERVAL '30 days'", c.inserted_at)
              )

            _ ->
              from(c in Channels)
          end

        :category_and_date ->
          query = from(c in Channels)

          query =
            if params[:category] && params[:category] != "all" do
              from(c in query, where: c.category == ^params[:category])
            else
              query
            end

          query =
            case params[:date] do
              "today" ->
                from(c in query, where: fragment("?::date = CURRENT_DATE", c.inserted_at))

              "week" ->
                from(c in query,
                  where: fragment("? >= CURRENT_DATE - INTERVAL '7 days'", c.inserted_at)
                )

              "month" ->
                from(c in query,
                  where: fragment("? >= CURRENT_DATE - INTERVAL '30 days'", c.inserted_at)
                )

              _ ->
                query
            end

          query

        :search ->
          search_term = "%#{String.downcase(params[:search_term])}%"

          from(a in Channels,
            where: fragment("lower(?) LIKE ?", a.name, ^search_term)
          )

        _ ->
          raise ArgumentError, "Unknown options: #{options}"
      end

    Repo.all(query)
  end

  @doc """
  Fetches all channels created by a specific user.

  ## Parameters
  - `user_id`: The ID of the user whose channels are to be fetched.

  ## Returns
  - A list of `Channels` belonging to the user.
  """
  def list_user_channels(user_id) do
    Channels
    |> where([c], c.user_id == ^user_id)
    |> select([c], %{name: c.name, id: c.id})
    |> Repo.all()
  end

  def user_has_channels?(user_id) do
    from(c in Channels, where: c.user_id == ^user_id)
    |> Repo.exists?()
  end

  @doc """
  Fetches all channels that belong to a specific category.

  ## Parameters
  - `category`: The category to filter channels by.

  ## Returns
  - A list of `Channels` that match the given category.
  """
  def list_channels_by_category(category) do
    from(c in Channels, where: ^category in c.category)
    |> Repo.all()
  end

  @doc """
  Fetches a single channel by its ID.

  ## Parameters
  - `id`: The ID of the channel to fetch.

  ## Returns
  - The `Channels` struct if found.

  ## Raises
  - `Ecto.NoResultsError` if no channel is found.
  """
  def get_channel!(id), do: Repo.get!(Channels, id)

  @doc """
  Updates a channel with the given attributes.

  ## Parameters
  - `channel`: The `Channels` struct to be updated.
  - `attrs`: A map of attributes to update the channel with.

  ## Returns
  - `{:ok, Channels}` if the update is successful.
  - `{:error, Ecto.Changeset}` if the update fails.
  """
  def update_channel(%Channels{} = channel, attrs) do
    channel
    |> Channels.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Fetches a list of channels similar to the given channel based on shared categories.

  ## Parameters
  - `channel`: The `Channels` struct to find similar channels for.

  ## Returns
  - A list of up to 3 `Channels` that share at least one category with the given channel,
    excluding the channel itself.
  """
  def list_similar_channels(%Channels{} = channel) do
    from(c in Channels,
      where: c.id != ^channel.id,
      where: fragment("? && ?", c.category, ^channel.category),
      limit: 3
    )
    |> Repo.all()
  end

  @doc """
  Counts the number of channels created by a specific user.

  ## Parameters
  - `user_id`: The ID of the user whose channels are to be counted.

  ## Returns
  - The total number of channels created by the user.
  """
  def count_user_channels(user_id) do
    from(c in Channels, where: c.user_id == ^user_id)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single channels.

  Raises `Ecto.NoResultsError` if the Channels does not exist.

  ## Examples

      iex> get_channels!(123)
      %Channels{}

      iex> get_channels!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channels!(id), do: Repo.get!(Channels, id)

  @doc """
  Creates a channels.

  ## Examples

      iex> create_channels(%{field: value})
      {:ok, %Channels{}}

      iex> create_channels(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channels(attrs \\ %{}) do
    %Channels{}
    |> Channels.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channels.

  ## Examples

      iex> update_channels(channels, %{field: new_value})
      {:ok, %Channels{}}

      iex> update_channels(channels, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channels(%Channels{} = channels, attrs) do
    channels
    |> Channels.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channels.

  ## Examples

      iex> delete_channels(channels)
      {:ok, %Channels{}}

      iex> delete_channels(channels)
      {:error, %Ecto.Changeset{}}

  """

  def delete_channels(%Channels{} = channel) do
    Repo.transaction(fn ->
      Repo.delete_all(from h in Headlines, where: h.channel_id == ^channel.id)

      Repo.delete(channel)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channels changes.

  ## Examples

      iex> change_channels(channels)
      %Ecto.Changeset{data: %Channels{}}

  """
  def change_channels(%Channels{} = channels, attrs \\ %{}) do
    Channels.changeset(channels, attrs)
  end

  # Subscriptions

  import Ecto.Query, warn: false
  alias Rednews.Repo
  alias Rednews.Accounts.Subscription

  @doc """
  Subscribes a user to another user's articles.

  Creates a new subscription if none exists, or updates an existing one to enable article subscriptions.

  ## Parameters
    - subscriber_id: ID of the user who is subscribing
    - target_user_id: ID of the user whose articles are being subscribed to

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def subscribe_to_user_articles(subscriber_id, target_user_id) do
    case get_subscription(subscriber_id, "user", target_user_id) do
      nil ->
        %Subscription{}
        |> Subscription.changeset(%{
          subscriber_id: subscriber_id,
          target_type: "user",
          target_id: target_user_id,
          subscribe_articles: true,
          subscribe_channels: false
        })
        |> Repo.insert()

      subscription ->
        subscription
        |> Subscription.changeset(%{subscribe_articles: true})
        |> Repo.update()
    end
  end

  @doc """
  Unsubscribes a user from another user's articles.

  Updates the subscription to disable article notifications or deletes it if no channel subscriptions remain.

  ## Parameters
    - subscriber_id: ID of the user who is unsubscribing
    - target_user_id: ID of the user whose articles are being unsubscribed from

  ## Returns
    - {:ok, %Subscription{}} or {:ok, nil} on success
    - {:error, changeset} on failure
  """
  def unsubscribe_from_user_articles(subscriber_id, target_user_id) do
    case get_subscription(subscriber_id, "user", target_user_id) do
      nil ->
        {:ok, nil}

      subscription ->
        if subscription.subscribe_channels do
          subscription
          |> Subscription.changeset(%{subscribe_articles: false})
          |> Repo.update()
        else
          Repo.delete(subscription)
        end
    end
  end

  @doc """
  Subscribes a user to another user's channels.

  Creates a new subscription if none exists, or updates an existing one to enable channel subscriptions.

  ## Parameters
    - subscriber_id: ID of the user who is subscribing
    - target_user_id: ID of the user whose channels are being subscribed to

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def subscribe_to_user_channels(subscriber_id, target_user_id) do
    case get_subscription(subscriber_id, "user", target_user_id) do
      nil ->
        %Subscription{}
        |> Subscription.changeset(%{
          subscriber_id: subscriber_id,
          target_type: "user",
          target_id: target_user_id,
          subscribe_articles: false,
          subscribe_channels: true
        })
        |> Repo.insert()

      subscription ->
        subscription
        |> Subscription.changeset(%{subscribe_channels: true})
        |> Repo.update()
    end
  end

  @doc """
  Unsubscribes a user from another user's channels.

  Updates the subscription to disable channel notifications or deletes it if no article subscriptions remain.

  ## Parameters
    - subscriber_id: ID of the user who is unsubscribing
    - target_user_id: ID of the user whose channels are being unsubscribed from

  ## Returns
    - {:ok, %Subscription{}} or {:ok, nil} on success
    - {:error, changeset} on failure
  """
  def unsubscribe_from_user_channels(subscriber_id, target_user_id) do
    case get_subscription(subscriber_id, "user", target_user_id) do
      nil ->
        {:ok, nil}

      subscription ->
        if subscription.subscribe_articles do
          subscription
          |> Subscription.changeset(%{subscribe_channels: false})
          |> Repo.update()
        else
          Repo.delete(subscription)
        end
    end
  end

  @doc """
  Subscribes a user to a specific channel.

  Creates a new channel subscription if none exists (handles conflicts gracefully).

  ## Parameters
    - subscriber_id: ID of the user who is subscribing
    - channel_id: ID of the channel being subscribed to

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def subscribe_to_channel(subscriber_id, channel_id) do
    %Subscription{}
    |> Subscription.changeset(%{
      subscriber_id: subscriber_id,
      target_type: "channel",
      target_id: channel_id,
      subscribe_articles: false,
      subscribe_channels: true
    })
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Unsubscribes a user from a specific channel.

  Deletes the channel subscription if it exists.

  ## Parameters
    - subscriber_id: ID of the user who is unsubscribing
    - channel_id: ID of the channel being unsubscribed from

  ## Returns
    - {:ok, %Subscription{}} or {:ok, nil} on success
    - {:error, changeset} on failure
  """
  def unsubscribe_from_channel(subscriber_id, channel_id) do
    case get_subscription(subscriber_id, "channel", channel_id) do
      nil -> {:ok, nil}
      subscription -> Repo.delete(subscription)
    end
  end

  @doc """
  Internal helper to find a specific subscription.

  ## Parameters
    - subscriber_id: ID of the subscribing user
    - target_type: "user" or "channel"
    - target_id: ID of the target being subscribed to

  ## Returns
    - %Subscription{} if found
    - nil if not found
  """
  defp get_subscription(subscriber_id, target_type, target_id) do
    Repo.one(
      from s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == ^target_type,
        where: s.target_id == ^target_id
    )
  end

  @doc """
  Subscribes a user to all content from another user (both articles and channels).

  Creates a new subscription with both flags enabled.

  ## Parameters
    - subscriber_id: ID of the user who is subscribing
    - target_user_id: ID of the user whose content is being subscribed to

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def subscribe_to_all_user_content(subscriber_id, target_user_id) do
    %Subscription{}
    |> Subscription.changeset(%{
      subscriber_id: subscriber_id,
      target_type: "user",
      target_id: target_user_id,
      subscribe_articles: true,
      subscribe_channels: true
    })
    |> Repo.insert()
  end

  @doc """
  Completely unsubscribes a user from another user (removes all subscriptions).

  Deletes all subscription records between these users.

  ## Parameters
    - subscriber_id: ID of the user who is unsubscribing
    - target_user_id: ID of the user being unsubscribed from

  ## Returns
    - {:ok, count} where count is number of records deleted
    - {:error, reason} on failure
  """
  def unsubscribe_from_user(subscriber_id, target_user_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "user",
        where: s.target_id == ^target_user_id
      )

    Repo.delete_all(query)
  end

  @doc """
  Checks if a user is subscribed to another user's articles.

  ## Parameters
    - subscriber_id: ID of the potential subscriber
    - target_user_id: ID of the user whose articles are being checked

  ## Returns
    - boolean: true if subscribed, false otherwise
  """
  def subscribed_to_user_articles?(subscriber_id, target_user_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "user",
        where: s.target_id == ^target_user_id,
        where: s.subscribe_articles == true
      )

    Repo.exists?(query)
  end

  @doc """
  Checks if a user is subscribed to another user's channels.

  ## Parameters
    - subscriber_id: ID of the potential subscriber
    - target_user_id: ID of the user whose channels are being checked

  ## Returns
    - boolean: true if subscribed, false otherwise
  """
  def subscribed_to_user_channels?(subscriber_id, target_user_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "user",
        where: s.target_id == ^target_user_id,
        where: s.subscribe_channels == true
      )

    Repo.exists?(query)
  end

  @doc """
  Checks if a user is subscribed to a specific channel.

  ## Parameters
    - subscriber_id: ID of the potential subscriber
    - channel_id: ID of the channel being checked

  ## Returns
    - boolean: true if subscribed, false otherwise
  """
  def subscribed_to_channel?(subscriber_id, channel_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "channel",
        where: s.target_id == ^channel_id,
        where: s.subscribe_channels == true
      )

    Repo.exists?(query)
  end

  @doc """
  Lists all subscriptions for a given user.

  ## Parameters
    - subscriber_id: ID of the user whose subscriptions to retrieve

  ## Returns
    - List of %Subscription{} records
  """
  def list_user_subscriptions(subscriber_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id
      )

    Repo.all(query)
  end

  @doc """
  Lists all user-to-user subscriptions for a given subscriber.

  ## Parameters
    - subscriber_id: ID of the user whose user subscriptions to retrieve

  ## Returns
    - List of %Subscription{} records where target_type is "user"
  """
  def list_user_subscriptions_to_users(subscriber_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "user"
      )

    Repo.all(query)
  end

  @doc """
  Lists all channel subscriptions for a given user.

  ## Parameters
    - subscriber_id: ID of the user whose channel subscriptions to retrieve

  ## Returns
    - List of %Subscription{} records where target_type is "channel"
  """
  def list_user_channel_subscriptions(subscriber_id) do
    query =
      from(s in Subscription,
        where: s.subscriber_id == ^subscriber_id,
        where: s.target_type == "channel"
      )

    Repo.all(query)
  end

  @doc """
  Updates a subscription with new attributes.

  ## Parameters
    - subscription_id: ID of the subscription to update
    - attrs: Map of attributes to change

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def update_subscription(subscription_id, %{} = attrs) do
    Subscription
    |> Repo.get(subscription_id)
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates subscription flags for a specific subscription.

  ## Parameters
    - subscription_id: ID of the subscription to update
    - subscribe_articles: boolean for article subscription status
    - subscribe_channels: boolean for channel subscription status

  ## Returns
    - {:ok, %Subscription{}} on success
    - {:error, changeset} on failure
  """
  def update_subscription_flags(subscription_id, subscribe_articles, subscribe_channels) do
    Subscription
    |> Repo.get(subscription_id)
    |> Subscription.changeset(%{
      subscribe_articles: subscribe_articles,
      subscribe_channels: subscribe_channels
    })
    |> Repo.update()
  end
end
