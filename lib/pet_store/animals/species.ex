defmodule PetStore.Animals.Species do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:name, :string, autogenerate: false}
  schema "species" do
    field :family, :string

    timestamps()
  end

  @doc false
  def changeset(species, attrs) do
    species
    |> cast(attrs, [:name, :family])
    |> validate_required([:name, :family])
  end
end
