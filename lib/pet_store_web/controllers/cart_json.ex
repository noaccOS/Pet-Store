defmodule PetStoreWeb.CartJSON do
  alias PetStore.Shop.Cart
  alias PetStoreWeb.PetJSON

  @doc """
  Renders a list of carts.
  """
  def index(%{carts: carts}) do
    %{data: for(cart <- carts, do: data(cart))}
  end

  @doc """
  Renders a single cart.
  """
  def show(%{cart: cart}) do
    %{data: data(cart)}
  end

  def data(%Cart{} = cart) do
    cart = cart |> PetStore.Repo.preload(:pets)

    %{
      id: cart.id,
      completed_on: cart.completed_on,
      pets: Enum.map(cart.pets, &PetJSON.data/1)
    }
  end
end
