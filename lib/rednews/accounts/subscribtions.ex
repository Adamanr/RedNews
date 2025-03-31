defmodule Rednews.Accounts.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @target_types ["user", "channel"]

  schema "subscriptions" do
    field :target_type, :string
    field :target_id, :integer
    field :subscribe_articles, :boolean, default: false
    field :subscribe_channels, :boolean, default: false

    belongs_to :subscriber, Rednews.Accounts.User

    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :subscriber_id,
      :target_type,
      :target_id,
      :subscribe_articles,
      :subscribe_channels
    ])
    |> validate_required([:subscriber_id, :target_type, :target_id])
    |> validate_inclusion(:target_type, @target_types)
    |> validate_subscription_flags()
    |> unique_constraint([:subscriber_id, :target_type, :target_id],
      name: :subscription_unique,
      message: "Already subscribed"
    )
  end

  defp validate_subscription_flags(changeset) do
    target_type = get_field(changeset, :target_type)

    cond do
      target_type == "channel" ->
        changeset
        |> put_change(:subscribe_articles, false)
        |> put_change(:subscribe_channels, true)

      true ->
        changeset
    end
  end
end
