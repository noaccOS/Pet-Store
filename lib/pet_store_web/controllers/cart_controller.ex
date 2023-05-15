defmodule PetStoreWeb.CartController do
  use PetStoreWeb, :controller

  alias PetStore.Shop
  alias PetStore.Shop.Cart
  alias PetStore.Animals

  action_fallback PetStoreWeb.FallbackController

  def index(conn, _params) do
    carts = Shop.list_carts()
    render(conn, :index, carts: carts)
  end

  def show(conn, %{"id" => id}) do
    cart = Shop.get_cart!(id)
    render(conn, :show, cart: cart)
  end

  def show_open(conn, %{"id" => user_id}) do
    cart = Shop.open_cart_for(user_id)
    render(conn, :show, cart: cart)
  end
end
