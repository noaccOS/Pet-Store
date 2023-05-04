defmodule PetStoreWeb.UserSettingsControllerTest do
  use PetStoreWeb.ConnCase, async: true

  alias PetStore.Accounts
  import PetStore.AccountsFixtures

  setup :register_and_log_in_user

  describe "PUT /users/settings (change password form)" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      new_password_conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_password",
          "current_password" => valid_user_password(),
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert new_password_conn.assigns[:user_token] != conn.assigns[:user_token]

      assert json_response(new_password_conn, 200)["message"] == "Password updated successfully."

      assert {:ok, _} =
               Accounts.fetch_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_password",
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert json_response(old_password_conn, 200)["message"] =~ "Password not updated"

      assert old_password_conn.assigns[:user_token] == conn.assigns[:user_token]
    end
  end

  describe "PUT /users/settings (change email form)" do
    @tag :capture_log
    test "updates the user email", %{conn: conn, user: user} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "current_password" => valid_user_password(),
          "user" => %{"email" => unique_user_email()}
        })

      assert json_response(conn, 200)["message"] =~
               "A link to confirm your email"

      assert {:ok, _} = Accounts.fetch_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      response = json_response(conn, 200)
      assert response["message"] == "There has been an error trying to change the email."
      assert response["status"] == "error"
    end
  end

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      user_token = conn.assigns.user_token
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      response = json_response(conn, 200)
      assert response["status"] == "ok"

      assert response["message"] =~
               "Email changed successfully"

      assert :error == Accounts.fetch_user_by_email(user.email)
      assert {:ok, _} = Accounts.fetch_user_by_email(email)

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{user_token}")
        |> get(~p"/users/settings/confirm_email/#{token}")

      response = json_response(conn, 200)

      assert response["status"] == "error"

      assert response["message"] =~
               "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/settings/confirm_email/oops")

      assert json_response(conn, 200)["message"] =~
               "Email change link is invalid or it has expired"

      assert {:ok, _} = Accounts.fetch_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end
end
