defmodule Rednews.Posts.Likes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :user, :id
    field :pub_type, :string
    field :pub_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:pub_id, :pub_type, :user])
    |> validate_required([:pub_id, :pub_type, :user])
    |> validate_inclusion(:pub_type, ["article", "headline"])
  end
end
