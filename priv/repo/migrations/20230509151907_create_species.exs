defmodule PetStore.Repo.Migrations.CreateSpecies do
  use Ecto.Migration

  def change do
    create table(:species) do
      add :name, :string
      add :family, :string

      timestamps()
    end
  end
end
