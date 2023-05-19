defmodule PetStore.AnimalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PetStore.Animals` context.
  """

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    species_name = attrs[:species_name] || "cat"
    maybe_insert_species(species_name)

    {:ok, pet} =
      attrs
      |> Enum.into(%{
        birthday: ~D[2023-05-08],
        name: "some name",
        species_name: species_name
      })
      |> PetStore.Animals.create_pet()

    pet
  end

  @doc """
  Generate a species.
  """
  def species_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "cat",
        family: "feline"
      })

    %PetStore.Animals.Species{}
    |> Ecto.Changeset.change(attrs)
    |> PetStore.Repo.insert!()
  end

  defp maybe_insert_species(name) do
    with {:error, _} <- PetStore.Repo.fetch(PetStore.Animals.Species, name) do
      species_fixture(%{name: name})
    end
  end
end
