defmodule PetStoreWeb.CartControllerTest do
  use PetStoreWeb.ConnCase

  import PetStore.ShopFixtures

  alias PetStore.Shop.Cart

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

  defp create_cart(_) do
    cart = cart_fixture()
    %{cart: cart}
  end
end
