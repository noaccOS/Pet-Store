defmodule PetStore.Animals.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :birthday, :date
    field :name, :string

    belongs_to :species, PetStore.Animals.Species,
      foreign_key: :species_name,
      references: :name,
      type: :string

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :birthday, :species_name])
    |> validate_required([:name, :birthday, :species_name])
    |> foreign_key_constraint(:species)
  end
end
