defmodule Rednews.Posts do
  @moduledoc """
  The Posts context.
  """

  def split_tag(attrs) do
    tags =
      case attrs["tags"] do
        nil -> "Новое"
        "" -> "Новое"
        tags -> tags
      end

    tags =
      tags
      |> String.split([", ", ","], trim: true)
      |> Enum.map(&String.capitalize/1)

    Map.put(attrs, "tags", tags)
  end

  @categories [
    "Политика",
    "Экономика",
    "Общество",
    "Культура",
    "Спорт",
    "Наука и технологии",
    "Здоровье",
    "Образование",
    "Происшествия",
    "Авто",
    "Недвижимость",
    "Туризм и путешествия",
    "Экология",
    "Мода и стиль",
    "Кино и телевидение",
    "Музыка",
    "Игры и развлечения",
    "Бизнес",
    "Финансы",
    "Мировые новости",
    "Региональные новости",
    "Технологии",
    "Криптовалюты",
    "Армия и оборона",
    "Сельское хозяйство",
    "Энергетика",
    "Транспорт",
    "Погода",
    "История",
    "Юмор"
  ]

  @doc """
  Return categories list `{label, value}`.
  """
  def list_categories, do: @categories

  import Ecto.Query, warn: false
  alias Rednews.Accounts
  alias Rednews.Repo

  @doc """
  Fetches the most popular tags from both articles and headlines.

  ## Parameters
  - `limit`: The maximum number of tags to return (default is 7).

  ## Returns
  - A list of tuples, where each tuple contains a tag and its count, sorted by count in descending order.
  """
  def get_popular_tags(limit \\ 7) do
    query = """
    SELECT tag, COUNT(*) as count
    FROM (
      SELECT unnest(tags) as tag FROM articles WHERE tags IS NOT NULL
      UNION ALL
      SELECT unnest(tags) as tag FROM headlines WHERE tags IS NOT NULL
    ) t
    GROUP BY tag
    ORDER BY count DESC
    LIMIT $1
    """

    Repo.query!(query, [limit]) |> Map.get(:rows)
  end

  @doc """
  Fetches the most popular categories from both articles and headlines.

  ## Parameters
  - `limit`: The maximum number of categories to return (default is 5).

  ## Returns
  - A list of tuples, where each tuple contains a category and its count, sorted by count in descending order.
  """
  def get_popular_categories(limit \\ 5) do
    query = """
    SELECT category, COUNT(*) as count
    FROM (
      SELECT category FROM articles WHERE category IS NOT NULL
      UNION ALL
      SELECT category FROM headlines WHERE category IS NOT NULL
    ) c
    GROUP BY category
    ORDER BY count DESC
    LIMIT $1
    """

    Repo.query!(query, [limit]) |> Map.get(:rows)
  end

  alias Rednews.Posts.Articles

  @doc """
  Lists articles based on the provided options and parameters.

  ## Parameters
  - `options`: The filtering option (default is `:default`).
    - `:default`: Fetches all articles.
    - `:category`: Filters articles by a specific category.
    - `:tags`: Filters articles by specific tags.
  - `params`: A map of parameters for filtering (e.g., `%{category: "tech", tags: ["elixir"]}`).

  ## Returns
  - A list of `Articles` matching the specified criteria.

  ## Raises
  - `ArgumentError` if an unknown option is provided.
  """
  def list_article(options \\ :default, params \\ %{}) do
    query =
      case options do
        :default -> from(a in Articles)
        :category -> from(a in Articles, where: a.category == ^params[:category])
        :tags -> from(a in Articles, where: ^params[:tags] in a.tags)
        _ -> raise ArgumentError, "Unknown options: #{options}"
      end

    Repo.all(query)
  end

  @doc """
  Fetches all articles created by a specific user.

  ## Parameters
  - `user_id`: The ID of the user whose articles are to be fetched.

  ## Returns
  - A list of `Articles` belonging to the user.
  """
  def list_user_articles(user_id) do
    Articles
    |> where([a], a.author == ^user_id)
    |> Repo.all()
  end

  @doc """
  Searches for articles by title using a case-insensitive partial match.

  ## Parameters
  - `title`: The title or part of the title to search for.

  ## Returns
  - A list of `Articles` whose titles match the search term.
  """
  def search_articles(title) do
    Articles
    |> where([a], like(a.title, ^"%#{title}%"))
    |> Repo.all()
  end

  @doc """
  Gets a single articles.

  Raises `Ecto.NoResultsError` if the Articles does not exist.

  ## Examples

      iex> get_articles!(123)
      %Articles{}

      iex> get_articles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_articles!(id), do: Repo.get!(Articles, id)

  @doc """
  Creates a articles.

  ## Examples

      iex> create_articles(%{field: value})
      {:ok, %Articles{}}

      iex> create_articles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_articles(attrs \\ %{}) do
    attrs = split_tag(attrs)

    %Articles{}
    |> Articles.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a articles.

  ## Examples

      iex> update_articles(articles, %{field: new_value})
      {:ok, %Articles{}}

      iex> update_articles(articles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_articles(%Articles{} = articles, attrs) do
    attrs = split_tag(attrs)

    articles
    |> Articles.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a articles.

  ## Examples

      iex> delete_articles(articles)
      {:ok, %Articles{}}

      iex> delete_articles(articles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_articles(%Articles{} = articles) do
    Repo.delete(articles)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking articles changes.

  ## Examples

      iex> change_articles(articles)
      %Ecto.Changeset{data: %Articles{}}

  """
  def change_articles(%Articles{} = articles, attrs \\ %{}) do
    Articles.changeset(articles, attrs)
  end

  alias Rednews.Posts.Headlines

  @doc """
  Returns the list of headlines.

  ## Examples

      iex> list_headlines()
      [%Headlines{}, ...]

  """
  def list_headlines(options \\ :default, params \\ %{}) do
    query =
      case options do
        :default -> from(h in Headlines)
        :category -> from(h in Headlines, where: h.category == ^params[:category])
        :tags -> from(h in Headlines, where: ^params[:tags] in h.tags)
        :channel -> from(h in Headlines, where: h.author == ^params[:channel])
        _ -> raise ArgumentError, "Unknown options: #{options}"
      end

    Repo.all(query)
  end

  @doc """
  Fetches the latest headline based on the insertion timestamp.

  ## Returns
  - The most recent `Headlines` struct if found.
  - `nil` if no headlines exist.
  """
  def get_latest_headline do
    query = from(h in Headlines, order_by: [desc: h.inserted_at], limit: 1)
    Repo.one(query)
  end

  @doc """
  Fetches all headlines that belong to a specific category.

  ## Parameters
  - `category`: The category to filter headlines by.

  ## Returns
  - A list of `Headlines` that match the given category.
  """
  def list_headline_by_category(category) do
    Headlines
    |> where([h], h.category == ^category)
    |> Repo.all()
  end

  @doc """
  Gets a single headlines.

  Raises `Ecto.NoResultsError` if the Headlines does not exist.

  ## Examples

      iex> get_headlines!(123)
      %Headlines{}

      iex> get_headlines!(456)
      ** (Ecto.NoResultsError)

  """
  def get_headlines!(id), do: Repo.get!(Headlines, id)

  @doc """
  Checks if the user is an author of any channel.

  Arguments:
    * user_id - The ID of the user (unused in current implementation)
    * author_id - The ID of the author to check in channels list

  Returns:
    * `true` if author_id exists in user's channels
    * `false` otherwise

  Examples:

      iex> me_author?(1, 2)
      true # if channel with id 2 exists in list

      iex> me_author?(1, 999)
      false # if no channel with id 999
  """
  @spec me_author?(integer(), integer()) :: boolean()
  def me_author?(user_id, author_id) when is_integer(author_id) do
    channels = Accounts.list_user_channels(user_id)
    Enum.any?(channels, fn channel -> channel.id == author_id end)
  end

  @doc """
  Creates a headlines.

  ## Examples

      iex> create_headlines(%{field: value})
      {:ok, %Headlines{}}

      iex> create_headlines(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_headlines(attrs \\ %{}) do
    attrs = split_tag(attrs)

    headlines = %Headlines{tags: attrs["tags"]}

    headlines
    |> Headlines.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a headlines.

  ## Examples

      iex> update_headlines(headlines, %{field: new_value})
      {:ok, %Headlines{}}

      iex> update_headlines(headlines, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_headlines(%Headlines{} = headlines, attrs) do
    attrs = split_tag(attrs)

    headlines
    |> Headlines.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a headlines.

  ## Examples

      iex> delete_headlines(headlines)
      {:ok, %Headlines{}}

      iex> delete_headlines(headlines)
      {:error, %Ecto.Changeset{}}

  """
  def delete_headlines(%Headlines{} = headlines) do
    Repo.delete(headlines)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking headlines changes.

  ## Examples

      iex> change_headlines(headlines)
      %Ecto.Changeset{data: %Headlines{}}

  """
  def change_headlines(%Headlines{} = headlines, attrs \\ %{}) do
    Headlines.changeset(headlines, attrs)
  end

  alias Rednews.Posts.Likes

  @doc """
  Counts the number of likes for a specific publication (article or headline).

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of publication (`:article` or `:headline`).

  ## Returns
  - The total number of likes for the publication.

  ## Raises
  - `ArgumentError` if an unknown publication type is provided.
  """
  def likes(pub_id, pub_type) do
    query =
      case pub_type do
        :article ->
          from(l in Likes, where: l.pub_id == ^pub_id and l.pub_type == ^to_string(pub_type))

        :headline ->
          from(l in Likes, where: l.pub_id == ^pub_id and l.pub_type == ^to_string(pub_type))

        _ ->
          raise ArgumentError, "Unknown publication type: #{pub_type}"
      end

    Repo.aggregate(query, :count)
  end

  @doc """
  Checks if a specific user has liked a specific publication.

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of publication (`:article` or `:headline`).
  - `user_id`: The ID of the user.

  ## Returns
  - `true` if the user has liked the publication, otherwise `false`.

  ## Raises
  - `ArgumentError` if an unknown publication type is provided.
  """
  def me_like?(pub_id, pub_type, user_id) do
    query =
      case pub_type do
        :article ->
          from(l in Likes,
            where:
              l.pub_id == ^pub_id and l.user == ^user_id and l.pub_type == ^to_string(pub_type)
          )

        :headline ->
          from(l in Likes,
            where:
              l.pub_id == ^pub_id and l.user == ^user_id and l.pub_type == ^to_string(pub_type)
          )

        _ ->
          raise ArgumentError, "Unknown publication type: #{pub_type}"
      end

    Repo.exists?(query)
  end

  @doc """
  Adds a like to a specific publication by a specific user.

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of publication (`:article` or `:headline`).
  - `user_id`: The ID of the user.

  ## Returns
  - `{:ok, like}` if the like is successfully added.
  - `{:error, changeset}` if the like could not be added.

  ## Raises
  - `ArgumentError` if an unknown publication type is provided.
  """
  def like(pub_id, pub_type, user_id) do
    %Likes{}
    |> Likes.changeset(%{pub_id: pub_id, pub_type: to_string(pub_type), user: user_id})
    |> Repo.insert()
    |> case do
      {:ok, like} -> {:ok, like}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Removes a like from a specific publication by a specific user.

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of publication (`:article` or `:headline`).
  - `user_id`: The ID of the user.

  ## Returns
  - `{:ok, :like_removed}` if the like is successfully removed.
  - `{:error, :not_found}` if the like does not exist.
  - `{:error, :unexpected_result}` if an unexpected number of likes are removed.

  ## Raises
  - `ArgumentError` if an unknown publication type is provided.
  """
  def unlike(pub_id, pub_type, user_id) do
    query =
      from(l in Likes,
        where: l.pub_id == ^pub_id and l.user == ^user_id and l.pub_type == ^to_string(pub_type)
      )

    case Repo.delete_all(query) do
      {0, _} -> {:error, :not_found}
      {1, _} -> {:ok, :like_removed}
      {_, _} -> {:error, :unexpected_result}
    end
  end

  alias Rednews.Posts.Comments
  alias Rednews.Accounts.User

  @doc """
  Creates a new comment.

  ## Parameters
  - `attrs`: A map of attributes for the comment. Defaults to an empty map.

  ## Returns
  - `{:ok, comment}`: If the comment is successfully created.
  - `{:error, changeset}`: If the comment creation fails due to validation errors or other issues.

  ## Examples
      iex> create_comment(%{content: "Great post!", pub_id: 1, pub_type: :headline, author: 1})
      {:ok, %Comments{}}
  """
  def create_comment(attrs \\ %{}) do
    %Comments{}
    |> Comments.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves all comments for a specific publication.

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of the publication (e.g., `:headline`, `:article`).

  ## Returns
  - A list of maps, where each map contains a `comment` and its associated `author`.

  ## Examples
      iex> get_comments(1, :headline)
      [%{comment: %Comments{}, author: %User{}}]

  """
  def get_comments(pub_id, pub_type) do
    Comments
    |> where([c], c.pub_id == ^pub_id and c.pub_type == ^pub_type)
    |> join(:inner, [c], u in User, on: c.author == u.id)
    |> select([c, u], %{comment: c, author: u})
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Retrieves all reply comments for a specific comment.

  ## Parameters
  - `pub_id`: The ID of the publication.
  - `pub_type`: The type of the publication (e.g., `:headline`, `:article`).
  - `com_id`: The ID of the parent comment.

  ## Returns
  - A list of maps, where each map contains a `comment` and its associated `author`.

  ## Examples
      iex> get_reply_comments(1, :headline, 5)
      [%{comment: %Comments{}, author: %User{}}]
  """
  def get_reply_comments(pub_id, pub_type, com_id) do
    Comments
    |> where([c], c.pub_id == ^pub_id and c.pub_type == ^pub_type and c.reply_id == ^com_id)
    |> join(:inner, [c], u in User, on: c.author == u.id)
    |> select([c, u], %{comment: c, author: u})
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Retrieves a single comment by its ID and publication type.

  ## Parameters
  - `com_id`: The ID of the comment.
  - `pub_type`: The type of the publication (e.g., `:headline`, `:article`).

  ## Returns
  - The comment if found, or `nil` if no comment matches the criteria.

  ## Examples
      iex> get_comment(1, :headline)
      %Comments{}
  """
  def get_comment(com_id, pub_type) do
    Comments
    |> where([c], c.id == ^com_id and c.pub_type == ^pub_type)
    |> Repo.one()
  end

  @doc """
  Deletes a comment and all its associated replies.

  ## Parameters
  - `id`: The ID of the comment to delete.

  ## Returns
  - `{:ok, deleted_comment}`: If the comment and its replies are successfully deleted.
  - `{:error, :not_found}`: If the comment does not exist.
  - `{:error, changeset}`: If the deletion fails due to database constraints or other issues.

  ## Examples
      iex> delete_comment(1)
      {:ok, %Comments{}}
  """
  def delete_comment(id) do
    Repo.transaction(fn ->
      case Repo.get(Comments, id) do
        nil ->
          Repo.rollback(:not_found)

        comment ->
          replies_query =
            from c in Comments,
              where: c.reply_id == ^id

          Repo.delete_all(replies_query)

          case Repo.delete(comment) do
            {:ok, deleted_comment} -> deleted_comment
            {:error, changeset} -> Repo.rollback(changeset)
          end
      end
    end)
  end
end
