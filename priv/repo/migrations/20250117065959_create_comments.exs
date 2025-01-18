defmodule Rednews.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :pub_type, :string
      add :pub_id, :integer
      add :content, :text
      add :author, references(:users, on_delete: :nothing)
      add :reply_id, references(:comments, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:author])
    create index(:comments, [:reply_id])
  end
end
