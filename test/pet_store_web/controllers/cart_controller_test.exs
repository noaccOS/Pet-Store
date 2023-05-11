defmodule PetStoreWeb.CartControllerTest do
  use PetStoreWeb.ConnCase

  import PetStore.ShopFixtures

  alias PetStore.Shop.Cart

  @create_attrs %{
    completed_on: ~N[2023-05-10 09:04:00]
  }
  @update_attrs %{
    completed_on: ~N[2023-05-11 09:04:00]
  }
  @invalid_attrs %{completed_on: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all carts", %{conn: conn} do
      conn = get(conn, ~p"/api/carts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create cart" do
    test "renders cart when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/carts", cart: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/carts/#{id}")

      assert %{
               "id" => ^id,
               "completed_on" => "2023-05-10T09:04:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/carts", cart: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update cart" do
    setup [:create_cart]

    test "renders cart when data is valid", %{conn: conn, cart: %Cart{id: id} = cart} do
      conn = put(conn, ~p"/api/carts/#{cart}", cart: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/carts/#{id}")

      assert %{
               "id" => ^id,
               "completed_on" => "2023-05-11T09:04:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, cart: cart} do
      conn = put(conn, ~p"/api/carts/#{cart}", cart: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete cart" do
    setup [:create_cart]

    test "deletes chosen cart", %{conn: conn, cart: cart} do
      conn = delete(conn, ~p"/api/carts/#{cart}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/carts/#{cart}")
      end
    end
  end

  defp create_cart(_) do
    cart = cart_fixture()
    %{cart: cart}
  end
end
