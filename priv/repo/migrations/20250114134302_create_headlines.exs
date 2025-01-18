defmodule Rednews.Repo.Migrations.CreateHeadlines do
  use Ecto.Migration

  def change do
    create table(:headlines) do
      add :title, :string
      add :content, :text
      add :category, :string
      add :is_fake, :boolean, null: true
      add :additional, :map
      add :is_very_important, :boolean, null: true
      add :header, :string
      add :tags, {:array, :string}
      add :author, references(:channels, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:headlines, [:author])
  end
end
