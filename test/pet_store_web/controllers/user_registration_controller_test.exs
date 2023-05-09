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

      errors = json_response(conn, 422)["errors"]
      assert "must have the @ sign and no spaces" in errors["email"]
      assert "should be at least 12 character(s)" in errors["password"]
    end

    test "doesn't log the user in if already authenticated", %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})

      email = unique_user_email()

      conn =
        post(conn, ~p"/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      response = json_response(conn, 200)
      assert response["data"]["email"] == email
    end
  end
end
