defmodule PetStoreWeb.PetController do
  use PetStoreWeb, :controller

  alias PetStore.Animals
  alias PetStore.Animals.Pet

  action_fallback PetStoreWeb.FallbackController

  def index(conn, _params) do
    pets = Animals.list_pets()
    render(conn, :index, pets: pets)
  end

  def create(conn, %{"pet" => pet_params}) do
    with {:ok, %Pet{} = pet} <- Animals.create_pet(pet_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/pets/#{pet}")
      |> render(:show, pet: pet)
    end
  end

  def show(conn, %{"id" => id}) do
    pet = Animals.fetch_pet!(id)
    render(conn, :show, pet: pet)
  end

  def update(conn, %{"id" => id, "pet" => pet_params}) do
    pet = Animals.fetch_pet!(id)

    with {:ok, %Pet{} = pet} <- Animals.update_pet(pet, pet_params) do
      render(conn, :show, pet: pet)
    end
  end

  def delete(conn, %{"id" => id}) do
    pet = Animals.fetch_pet!(id)

    with {:ok, %Pet{}} <- Animals.delete_pet(pet) do
      render(conn, :show, pet: pet)
    end
  end
end
