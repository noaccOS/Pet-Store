defmodule PetStore.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :completed_on, :naive_datetime
      add :user, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:carts, [:user])
  end
end
