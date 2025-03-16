defmodule Rednews.Accounts.Channels do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :links, :string
    field :name, :string
    field :header, :string
    field :desc, :string
    field :category
    field :is_verificated, :boolean
    field :logo, :string
    field :additional, :map

    has_many :headlines, Rednews.Posts.Headlines, foreign_key: :channel_id

    belongs_to :user, Rednews.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channels, attrs) do
    channels
    |> cast(attrs, [:name, :desc, :logo, :header, :category, :links, :user_id])
    |> validate_required([:name, :logo, :desc, :header, :category, :links, :user_id])
  end
end
