defmodule PetStore.Repo.Migrations.AddCartFieldToPet do
  use Ecto.Migration

  def change do
    alter table(:pets) do
      add :cart_id, references(:carts, on_delete: :nullify)
    end
  end
end
