defmodule PetStore.Repo.Migrations.CreatePets do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string
      add :birthday, :date
      add :species_name, references(:species, type: :string, column: :name, on_delete: :nothing)

      timestamps()
    end

    create index(:pets, [:species_name])
  end
end
