defmodule Rednews.Repo.Migrations.CreateArticle do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :content, :text
      add :is_fake, :boolean, null: true
      add :category, :string
      add :tags, {:array, :string}
      add :additional, :map
      add :author, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:author])
    create index(:articles, [:title])
    create index(:articles, [:category])
    create index(:articles, [:tags])
  end
end
