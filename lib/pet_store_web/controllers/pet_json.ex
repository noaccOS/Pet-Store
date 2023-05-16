defmodule PetStoreWeb.PetJSON do
  alias PetStore.Animals.Pet

  @doc """
  Renders a list of pets.
  """
  def index(%{pets: pets}) do
    %{data: for(pet <- pets, do: data(pet))}
  end

  @doc """
  Renders a single pet.
  """
  def show(%{pet: pet}) do
    %{data: data(pet)}
  end

  def data(%Pet{} = pet) do
    %{
      id: pet.id,
      name: pet.name,
      birthday: pet.birthday
    }
  end
end
