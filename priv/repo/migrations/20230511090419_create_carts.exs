defmodule PetStore.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :completed_on, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:carts, [:user_id])
  end
end
