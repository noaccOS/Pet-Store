defmodule PetStoreWeb.CartControllerTest do
  use PetStoreWeb.ConnCase

  alias PetStore.Animals
  alias PetStore.Shop
  import PetStore.ShopFixtures
  import PetStore.AnimalsFixtures

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user = PetStore.AccountsFixtures.user_fixture()
    admin = PetStore.AccountsFixtures.user_fixture(admin_level: 1)

    %{
      conn: conn,
      user_conn: log_in_user(conn, user),
      admin_conn: log_in_user(conn, admin),
      user: user,
      admin: admin
    }
  end

  describe "index" do
    test "lists all carts if admin account", %{admin_conn: conn} do
      conn = get(conn, ~p"/carts")
      assert json_response(conn, 200)["data"]
    end

    test "errors out with normal user", %{user_conn: conn} do
      conn
      |> get(~p"/carts")
      |> response(403)
    end

    test "errors out when unauthenticated", %{conn: conn} do
      conn
      |> get(~p"/carts")
      |> response(401)
    end
  end

  describe "show" do
    setup [:create_cart]

    test "shows the cart if admin", %{admin_conn: conn, cart: cart} do
      conn = get(conn, ~p"/carts/#{cart}")
      assert json_response(conn, 200)["data"]
    end

    test "errors out with normal user", %{user_conn: conn, cart: cart} do
      conn
      |> get(~p"/carts/#{cart}")
      |> response(403)
    end

    test "errors out when unauthenticated", %{conn: conn, cart: cart} do
      conn
      |> get(~p"/carts/#{cart}")
      |> response(401)
    end
  end

  describe "show_open" do
    setup [:create_cart]

    test "shows the cart if same user", %{user_conn: conn, user: user} do
      conn = get(conn, ~p"/users/#{user}/cart")
      assert json_response(conn, 200)["data"]
    end

    test "shows the cart if higher admin", %{user: user, admin_conn: admin_conn} do
      conn = get(admin_conn, ~p"/users/#{user}/cart")
      assert json_response(conn, 200)["data"]
    end

    test "errors out when unauthenticated", %{conn: conn, user: user} do
      conn
      |> get(~p"/users/#{user}/cart")
      |> response(401)
    end
  end

  describe "add_to_cart" do
    setup [:create_pet]

    test "adds the pet to the open cart", %{user_conn: conn, pet: pet, user: user} do
      conn = patch(conn, ~p"/pets/#{pet.id}/add")
      assert json_response(conn, 200)

      pet = Animals.fetch_pet!(pet.id)
      user_cart = Shop.open_cart_for(user)

      assert pet.cart_id == user_cart.id
    end
  end

  describe "checkout" do
    setup [:create_pet]

    test "checkouts open cart for current user", %{user_conn: conn, pet: pet, user: user} do
      cart = Shop.open_cart_for(user)

      Shop.add_to_cart(cart, pet)

      refute cart.completed_on

      conn
      |> patch(~p"/checkout")
      |> json_response(200)

      assert Shop.fetch_cart!(cart.id).completed_on
    end

    test "errors out on empty cart", %{user_conn: conn} do
      conn
      |> patch(~p"/checkout")
      |> response(400)
    end
  end

  describe "empty_by_open" do
    setup [:create_pet]

    test "removes all pets from the user's open cart", %{user_conn: conn, pet: pet, user: user} do
      cart = Shop.open_cart_for(user)

      Shop.add_to_cart(cart, pet)
      refute Shop.is_empty?(cart)

      conn
      |> post(~p"/empty")
      |> json_response(200)

      assert Shop.is_empty?(cart, force_refetch: true)
    end

    test "errors out on unauthenticated conn", %{conn: conn} do
      conn
      |> post(~p"/empty")
      |> response(401)
    end
  end

  defp create_cart(_) do
    cart = cart_fixture()
    %{cart: cart}
  end

  defp create_pet(_) do
    pet = pet_fixture()
    %{pet: pet}
  end
end
