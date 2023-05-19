defmodule PetStoreWeb.CartController do
  use PetStoreWeb, :controller

  alias PetStore.Shop
  alias PetStore.Animals
  alias PetStore.Accounts

  action_fallback PetStoreWeb.FallbackController

  def index(conn, _params) do
    carts = Shop.list_carts()
    render(conn, :index, carts: carts)
  end

  def show(conn, %{"id" => id}) do
    cart = Shop.fetch_cart!(id)
    render(conn, :show, cart: cart)
  end

  def show_open(conn, %{"id" => user_id}) do
    with {:ok, target} <- Accounts.fetch_user(user_id),
         :ok <-
           Bodyguard.permit(
             PetStoreWeb.Authorization,
             :access_cart,
             conn.assigns.current_user,
             target
           ),
         cart = Shop.open_cart_for(target),
         do: render(conn, :show, cart: cart)
  end

  def add_to_cart(conn, %{"id" => pet_id}) do
    user = conn.assigns.current_user
    cart = Shop.open_cart_for(user)

    with {:ok, pet} <- Animals.fetch_pet(pet_id),
         {:ok, _new_pet} <- Shop.add_to_cart(cart, pet) do
      render(conn, :show, cart: cart)
    end
  end

  def checkout(conn, _params) do
    user = conn.assigns.current_user
    cart = Shop.open_cart_for(user)

    with {:ok, cart} <- Shop.checkout(cart),
         do: render(conn, :show, cart: cart)
  end

  def empty_by_open(conn, _params),
    do: conn.assigns.current_user |> Shop.open_cart_for() |> do_empty_cart(conn)

  defp do_empty_cart(cart, conn) do
    Shop.empty(cart)
    cart = PetStore.Repo.preload(cart, :pets, force: true)
    render(conn, :show, cart: cart)
  end
end
