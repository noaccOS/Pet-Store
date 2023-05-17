defmodule PetStore.ShopTest do
  use PetStore.DataCase

  alias PetStore.Shop

  describe "carts" do
    alias PetStore.Shop.Cart

    import PetStore.ShopFixtures

    @invalid_attrs %{user_id: nil}

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert Shop.list_carts() == [cart]
    end

    test "fetch_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert Shop.fetch_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart" do
      valid_id = PetStore.AccountsFixtures.user_fixture().id
      valid_attrs = %{user_id: valid_id}

      assert {:ok, %Cart{} = cart} = Shop.create_cart(valid_attrs)
      assert cart.user_id == valid_id
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shop.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart = cart_fixture()
      update_attrs = %{completed_on: ~N[2023-05-11 09:04:00]}

      assert {:ok, %Cart{} = cart} = Shop.update_cart(cart, update_attrs)
      assert cart.completed_on == ~N[2023-05-11 09:04:00]
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = Shop.update_cart(cart, @invalid_attrs)
      assert cart == Shop.fetch_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = Shop.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> Shop.fetch_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = Shop.change_cart(cart)
    end

    test "add_to_cart/2 inserts an element in the cart" do
      cart = cart_fixture()
      pet = PetStore.AnimalsFixtures.pet_fixture()

      cart = PetStore.Repo.preload(cart, :pets)
      n1 = Enum.count(cart.pets)

      Shop.add_to_cart(cart, pet)
      cart = PetStore.Repo.preload(cart, :pets, force: true)
      n2 = Enum.count(cart.pets)

      assert n2 > n1
      assert pet.id in Enum.map(cart.pets, fn p -> p.id end)
    end

    test "add_to_cart/2 doesn't add a pet present in another cart" do
      cart1 = cart_fixture()
      cart2 = cart_fixture()
      pet = PetStore.AnimalsFixtures.pet_fixture()

      assert {:ok, pet} = Shop.add_to_cart(cart1, pet)
      assert {:error, _} = Shop.add_to_cart(cart2, pet)
    end
  end
end
