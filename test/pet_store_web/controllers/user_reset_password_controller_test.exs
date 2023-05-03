defmodule PetStoreWeb.UserResetPasswordControllerTest do
  use PetStoreWeb.ConnCase, async: true

  alias PetStore.Accounts
  alias PetStore.Repo
  import PetStore.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/reset_password", %{
          "user" => %{"email" => user.email}
        })

      response = json_response(conn, 200)
      assert response["status"] == "ok"
      assert response["message"] =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/users/reset_password", %{
          "user" => %{"email" => "unknown@example.com"}
        })

      response = json_response(conn, 200)
      assert response["status"] == "ok"
      assert response["message"] =~ "If your email is in our system"

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "PUT /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, ~p"/users/reset_password/#{token}", %{
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert {:ok, _} =
               Accounts.fetch_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"/users/reset_password/#{token}", %{
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = json_response(conn, 200)
      assert response["status"] == "error"
      assert response["message"] == "Error encountered during password reset."
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, ~p"/users/reset_password/oops")

      response = json_response(conn, 200)
      assert response["status"] == "error"
      assert response["message"] == "Reset password link is invalid or it has expired."
    end
  end
end
