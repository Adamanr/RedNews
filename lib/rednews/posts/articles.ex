defmodule Rednews.Posts.Articles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :content, :string
    field :is_fake, :boolean
    field :category, :string
    field :tags, {:array, :string}
    field :additional, :map
    field :author, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(articles, attrs) do
    articles
    |> cast(attrs, [:title, :content, :category, :tags, :author])
    |> validate_required([:title, :content, :category, :tags])
    |> validate_length(:tags, min: 2)
  end
end
