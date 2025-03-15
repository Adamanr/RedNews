defmodule Rednews.Posts.Articles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :content, :string
    field :header, :string
    field :category, :string
    field :tags, {:array, :string}
    field :additional, :map

    belongs_to :user, Rednews.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(articles, attrs) do
    articles
    |> cast(attrs, [:title, :content, :category, :header, :user_id, :additional])
    |> validate_required([:title, :content, :category, :header, :user_id])
  end
end
