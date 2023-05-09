defmodule PetStoreWeb.PetControllerTest do
  use PetStoreWeb.ConnCase

  import PetStore.AnimalsFixtures

  alias PetStore.Animals.Pet

  @create_attrs %{
    birthday: ~D[2023-05-08],
    name: "some name"
  }
  @update_attrs %{
    birthday: ~D[2023-05-09],
    name: "some updated name"
  }
  @invalid_attrs %{birthday: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all pets", %{conn: conn} do
      conn = get(conn, ~p"/api/pets")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create pet" do
    test "renders pet when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/pets", pet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/pets/#{id}")

      assert %{
               "id" => ^id,
               "birthday" => "2023-05-08",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/pets", pet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update pet" do
    setup [:create_pet]

    test "renders pet when data is valid", %{conn: conn, pet: %Pet{id: id} = pet} do
      conn = put(conn, ~p"/api/pets/#{pet}", pet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/pets/#{id}")

      assert %{
               "id" => ^id,
               "birthday" => "2023-05-09",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, pet: pet} do
      conn = put(conn, ~p"/api/pets/#{pet}", pet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete pet" do
    setup [:create_pet]

    test "deletes chosen pet", %{conn: conn, pet: pet} do
      conn = delete(conn, ~p"/api/pets/#{pet}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/pets/#{pet}")
      end
    end
  end

  defp create_pet(_) do
    pet = pet_fixture()
    %{pet: pet}
  end
end
