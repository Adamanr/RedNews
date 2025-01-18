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
    field :author, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channels, attrs) do
    channels
    |> cast(attrs, [:name, :desc, :logo, :header, :category, :links, :author])
    |> validate_required([:name, :desc, :logo, :header, :category, :links, :author])
  end
end
