defmodule Rednews.Posts.Headlines do
  use Ecto.Schema
  import Ecto.Changeset

  schema "headlines" do
    field :header, :string
    field :title, :string
    field :category, :string
    field :content, :string
    field :is_fake, :boolean
    field :additional, :map
    field :is_very_important, :boolean
    field :tags, {:array, :string}
    field :author, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(headlines, attrs) do
    headlines
    |> cast(attrs, [:title, :content, :category, :header, :tags, :author])
    |> validate_required([:title, :content, :category, :header, :author])
  end
end
