defmodule PetStoreWeb.UserSessionControllerTest do
  use PetStoreWeb.ConnCase, async: true

  import PetStore.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      token = conn.assigns[:user_token]
      assert token

      # Now do a logged in request and assert the outcome
      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/users/log_out")

      response = json_response(conn, 200)
      assert response["status"] == "ok"
      assert response["message"] == "User logged out successfully."
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      assert json_response(conn, 404)
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      refute conn.assigns[:user_token]

      response = json_response(conn, 200)
      assert response["status"] == "ok"
      assert response["message"] == "User logged out successfully."
    end

    test "fails if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")

      %{status: status} = conn
      assert status == 401
    end
  end
end
