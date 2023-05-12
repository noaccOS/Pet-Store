defmodule PetStoreWeb.CartController do
  use PetStoreWeb, :controller

  alias PetStore.Shop
  alias PetStore.Shop.Cart

  action_fallback PetStoreWeb.FallbackController

  def index(conn, _params) do
    carts = Shop.list_carts()
    render(conn, :index, carts: carts)
  end

  def show(conn, %{"id" => id}) do
    cart = Shop.get_cart!(id)
    render(conn, :show, cart: cart)
  end
end
