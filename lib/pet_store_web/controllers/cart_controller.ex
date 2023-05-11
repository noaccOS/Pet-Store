defmodule PetStoreWeb.CartController do
  use PetStoreWeb, :controller

  alias PetStore.Shop
  alias PetStore.Shop.Cart

  action_fallback PetStoreWeb.FallbackController

  def index(conn, _params) do
    carts = Shop.list_carts()
    render(conn, :index, carts: carts)
  end

  def create(conn, %{"cart" => cart_params}) do
    with {:ok, %Cart{} = cart} <- Shop.create_cart(cart_params) do
      conn
      |> put_status(:created)
      |> render(:show, cart: cart)
    end
  end

  def show(conn, %{"id" => id}) do
    cart = Shop.get_cart!(id)
    render(conn, :show, cart: cart)
  end

  def update(conn, %{"id" => id, "cart" => cart_params}) do
    cart = Shop.get_cart!(id)

    with {:ok, %Cart{} = cart} <- Shop.update_cart(cart, cart_params) do
      render(conn, :show, cart: cart)
    end
  end

  def delete(conn, %{"id" => id}) do
    cart = Shop.get_cart!(id)

    with {:ok, %Cart{}} <- Shop.delete_cart(cart) do
      send_resp(conn, :no_content, "")
    end
  end
end
