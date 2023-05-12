defmodule PetStoreWeb.PetControllerTest do
  use PetStoreWeb.ConnCase

  import PetStore.AnimalsFixtures

  alias PetStore.Animals.Pet

  @create_attrs %{
    birthday: ~D[2023-05-08],
    name: "some name",
    species_name: "cat"
  }
  @update_attrs %{
    birthday: ~D[2023-05-09],
    name: "some updated name"
  }
  @invalid_attrs %{birthday: nil, name: nil}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    user = PetStore.AccountsFixtures.user_fixture()
    admin = PetStore.AccountsFixtures.user_fixture(admin_level: 1)
    %{conn: conn, user_conn: log_in_user(conn, user), admin_conn: log_in_user(conn, admin)}
  end

  describe "index" do
    test "lists all pets", %{conn: conn} do
      conn = get(conn, ~p"/pets")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create pet" do
    test "renders pet when data is valid", %{admin_conn: admin_conn} do
      species_name = @create_attrs.species_name
      PetStore.AnimalsFixtures.species_fixture(%{name: species_name})
      conn = post(admin_conn, ~p"/pets", pet: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/pets/#{id}")

      assert %{
               "id" => ^id,
               "birthday" => "2023-05-08",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{admin_conn: admin_conn} do
      conn = post(admin_conn, ~p"/pets", pet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update pet" do
    setup [:create_pet]

    test "renders pet when data is valid and user is admin", %{
      admin_conn: admin_conn,
      pet: %Pet{id: id} = pet
    } do
      conn = put(admin_conn, ~p"/pets/#{pet}", pet: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/pets/#{id}")

      assert %{
               "id" => ^id,
               "birthday" => "2023-05-09",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{admin_conn: admin_conn, pet: pet} do
      conn = put(admin_conn, ~p"/pets/#{pet}", pet: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete pet" do
    setup [:create_pet]

    test "can't delete pet as normal user/unauthenticated", %{
      conn: conn,
      user_conn: user_conn,
      pet: pet
    } do
      unauthenticated = delete(conn, ~p"/pets/#{pet}")
      assert %{status: 401, state: :sent} = unauthenticated

      user_conn = delete(user_conn, ~p"/pets/#{pet}")
      assert %{status: 403, state: :sent} = user_conn
    end

    test "deletes chosen pet", %{admin_conn: admin_conn, pet: pet} do
      conn = delete(admin_conn, ~p"/pets/#{pet}")
      assert json_response(conn, 200)

      assert_error_sent 404, fn ->
        get(admin_conn, ~p"/pets/#{pet}")
      end
    end
  end

  defp create_pet(_) do
    pet = pet_fixture()
    %{pet: pet}
  end
end
