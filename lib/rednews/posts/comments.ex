defmodule Rednews.Posts.Comments do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :pub_type, :string
    field :pub_id, :integer
    field :content, :string
    field :author, :id
    field :reply_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comments, attrs) do
    comments
    |> cast(attrs, [:pub_type, :pub_id, :content, :author, :reply_id])
    |> validate_required([:pub_type, :pub_id, :content, :author])
    |> validate_length(:content, min: 1, max: 1000)
  end
end
