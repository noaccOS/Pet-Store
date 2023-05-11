defmodule PetStore.ShopFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PetStore.Shop` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        completed_on: ~N[2023-05-10 09:04:00]
      })
      |> PetStore.Shop.create_cart()

    cart
  end
end
