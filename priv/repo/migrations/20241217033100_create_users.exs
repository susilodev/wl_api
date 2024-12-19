defmodule WlApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :username, :string, size: 15, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :status, :string, default: "nil"
      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
