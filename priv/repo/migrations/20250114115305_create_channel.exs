defmodule Rednews.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :desc, :text
      add :is_verificated, :boolean, null: true
      add :logo, :string
      add :header, :string
      add :additional, :map
      add :category, :string
      add :links, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:user_id])
  end
end
