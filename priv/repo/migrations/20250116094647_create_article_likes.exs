defmodule Rednews.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :user, references(:users, on_delete: :nothing)
      add :pub_type, :string
      add :pub_id, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:likes, [:user])
    create index(:likes, [:pub_type, :pub_id])
  end
end
