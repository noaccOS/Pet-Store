defmodule PetStore.Animals.Species do
  use Ecto.Schema
  import Ecto.Changeset

  schema "species" do
    field :family, :string
    field :name, :string, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(species, attrs) do
    species
    |> cast(attrs, [:name, :family])
    |> validate_required([:name, :family])
  end
end
