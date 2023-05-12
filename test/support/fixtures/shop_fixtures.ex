defmodule PetStore.ShopFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PetStore.Shop` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    user_id =
      attrs[:user_id] ||
        PetStore.AccountsFixtures.user_fixture().id

    {:ok, cart} =
      attrs
      |> Enum.into(%{
        user_id: user_id
      })
      |> PetStore.Shop.create_cart()

    cart
  end
end
