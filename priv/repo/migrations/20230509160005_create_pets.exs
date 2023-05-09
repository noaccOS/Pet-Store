defmodule PetStore.Repo.Migrations.CreatePets do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string
      add :birthday, :date
      add :species, references(:species, on_delete: :nothing)

      timestamps()
    end

    create index(:pets, [:species])
  end
end
