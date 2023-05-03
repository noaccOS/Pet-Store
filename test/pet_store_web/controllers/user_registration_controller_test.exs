defmodule PetStoreWeb.UserRegistrationControllerTest do
  use PetStoreWeb.ConnCase, async: true

  import PetStore.AccountsFixtures

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      conn_token = conn.assigns[:user_token]
      assert conn_token

      response = json_response(conn, 200)
      token = response["token"]
      assert conn_token == token

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/users/log_out")

      response = json_response(conn, 200)
      assert response["status"] == "ok"
      assert response["message"] == "User logged out successfully."
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/users/register", %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = json_response(conn, 200)
      assert response["status"] == "error"
      assert response["message"] == "Error during user creation. Please try again."
    end
  end
end
