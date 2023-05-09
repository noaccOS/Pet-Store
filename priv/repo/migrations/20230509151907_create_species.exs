defmodule PetStore.Repo.Migrations.CreateSpecies do
  use Ecto.Migration

  def change do
    create table(:species, primary_key: false) do
      add :name, :string, primary_key: true
      add :family, :string

      timestamps()
    end

    create index(:species, [:family])
  end
end
