defmodule PetStore.ShopTest do
  use PetStore.DataCase

  alias PetStore.Shop

  describe "carts" do
    alias PetStore.Shop.Cart

    import PetStore.ShopFixtures
    import PetStore.AccountsFixtures
    import PetStore.AnimalsFixtures

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

    test "is_empty?/1" do
      cart = cart_fixture()
      pet = PetStore.AnimalsFixtures.pet_fixture()

      assert Shop.is_empty?(cart)

      Shop.add_to_cart(cart, pet)
      refute Shop.is_empty?(cart, force_refetch: true)
    end

    test "checkout/1" do
      cart = cart_fixture()
      refute cart.completed_on

      assert {:error, :bad_request} == Shop.checkout(cart)
      pet = PetStore.AnimalsFixtures.pet_fixture()
      {:ok, _} = Shop.add_to_cart(cart, pet)

      {:ok, cart} = Shop.checkout(cart, force_refetch: true)
      assert cart.completed_on
    end

    test "empty/1" do
      cart = cart_fixture()

      assert Shop.is_empty?(cart)

      Shop.empty(cart)
      assert Shop.is_empty?(cart)

      pet1 = PetStore.AnimalsFixtures.pet_fixture(name: "first")
      pet2 = PetStore.AnimalsFixtures.pet_fixture(name: "second")
      Shop.add_to_cart(cart, pet1)
      Shop.add_to_cart(cart, pet2)
      refute Shop.is_empty?(cart)

      Shop.empty(cart)
      assert Shop.is_empty?(cart)
    end

    test "gift_pet/2" do
      original_owner = user_fixture()
      owners_cart = Shop.open_cart_for(original_owner)

      recipient = user_fixture()
      recipients_cart = Shop.open_cart_for(recipient)

      pet = pet_fixture()

      {:ok, pet} = Shop.add_to_cart(owners_cart, pet)
      Shop.checkout(owners_cart, force_refetch: true)

      {:ok, pet} = Shop.gift_pet(pet, recipient)
      new_cart = Shop.fetch_cart!(pet.cart_id)

      # It's a new cart, but of the same user
      assert new_cart.id != recipients_cart.id
      assert new_cart.user_id == recipients_cart.user_id

      # The new cart is completed while the old one should be left untouched
      assert new_cart.completed_on
      refute recipients_cart.completed_on

      assert Shop.open_cart_for(recipient).id == recipients_cart.id

      refute pet in (Shop.fetch_cart!(owners_cart.id)
                     |> Repo.preload(:pets)
                     |> get_in([Access.key!(:pets)]))
    end
  end
end
