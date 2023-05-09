defmodule PetStore.Animals.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :birthday, :date
    field :name, :string
    field :species, :id

    timestamps()
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :birthday])
    |> validate_required([:name, :birthday])
  end
end
