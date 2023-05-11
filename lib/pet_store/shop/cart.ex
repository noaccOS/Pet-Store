defmodule PetStore.Shop.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    field :completed_on, :naive_datetime
    field :user, :id

    timestamps()
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:completed_on])
    |> validate_required([:completed_on])
  end
end
