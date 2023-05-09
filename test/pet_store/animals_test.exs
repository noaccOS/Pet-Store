defmodule PetStore.AnimalsTest do
  use PetStore.DataCase

  alias PetStore.Animals

  describe "pets" do
    alias PetStore.Animals.Pet

    import PetStore.AnimalsFixtures

    @invalid_attrs %{birthday: nil, name: nil}

    test "list_pets/0 returns all pets" do
      pet = pet_fixture()
      assert Animals.list_pets() == [pet]
    end

    test "get_pet!/1 returns the pet with given id" do
      pet = pet_fixture()
      assert Animals.get_pet!(pet.id) == pet
    end

    test "create_pet/1 with valid data creates a pet" do
      valid_attrs = %{birthday: ~D[2023-05-08], name: "some name"}

      assert {:ok, %Pet{} = pet} = Animals.create_pet(valid_attrs)
      assert pet.birthday == ~D[2023-05-08]
      assert pet.name == "some name"
    end

    test "create_pet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Animals.create_pet(@invalid_attrs)
    end

    test "update_pet/2 with valid data updates the pet" do
      pet = pet_fixture()
      update_attrs = %{birthday: ~D[2023-05-09], name: "some updated name"}

      assert {:ok, %Pet{} = pet} = Animals.update_pet(pet, update_attrs)
      assert pet.birthday == ~D[2023-05-09]
      assert pet.name == "some updated name"
    end

    test "update_pet/2 with invalid data returns error changeset" do
      pet = pet_fixture()
      assert {:error, %Ecto.Changeset{}} = Animals.update_pet(pet, @invalid_attrs)
      assert pet == Animals.get_pet!(pet.id)
    end

    test "delete_pet/1 deletes the pet" do
      pet = pet_fixture()
      assert {:ok, %Pet{}} = Animals.delete_pet(pet)
      assert_raise Ecto.NoResultsError, fn -> Animals.get_pet!(pet.id) end
    end

    test "change_pet/1 returns a pet changeset" do
      pet = pet_fixture()
      assert %Ecto.Changeset{} = Animals.change_pet(pet)
    end
  end
end
