defmodule PetStore.Shop.Cart do
  use Ecto.Schema
  alias PetStore.Accounts.User
  alias PetStore.Animals.Pet
  import Ecto.Changeset

  schema "carts" do
    field :completed_on, :naive_datetime
    belongs_to :user, User
    has_many :pets, Pet

    timestamps()
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:completed_on])
    |> validate_required([:completed_on])
  end
end
