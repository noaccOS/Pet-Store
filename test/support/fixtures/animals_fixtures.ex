defmodule PetStore.AnimalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PetStore.Animals` context.
  """

  @doc """
  Generate a pet.
  """
  def pet_fixture(attrs \\ %{}) do
    {:ok, pet} =
      attrs
      |> Enum.into(%{
        birthday: ~D[2023-05-08],
        name: "some name"
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
end
