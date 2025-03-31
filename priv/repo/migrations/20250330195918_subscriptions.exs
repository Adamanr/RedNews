defmodule Rednews.Repo.Migrations.Subscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :subscriber_id, references(:users, on_delete: :delete_all), null: false
      add :target_type, :string, null: false
      add :target_id, :integer, null: false
      add :subscribe_articles, :boolean, default: false
      add :subscribe_channels, :boolean, default: false

      timestamps()
    end

    create index(:subscriptions, [:subscriber_id])
    create index(:subscriptions, [:target_type, :target_id])

    create unique_index(:subscriptions, [:subscriber_id, :target_type, :target_id],
             name: :subscription_unique
           )
  end
end
