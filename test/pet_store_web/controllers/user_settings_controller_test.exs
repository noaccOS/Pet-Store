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

      # Erros assertions
      errors = json_response(old_password_conn, 422)["errors"]
      assert "is not valid" in errors["current_password"]
      assert "should be at least 12 character(s)" in errors["password"]
      assert "does not match password" in errors["password_confirmation"]

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

      errors = json_response(conn, 422)["errors"]
      assert "is not valid" in errors["current_password"]
      assert "must have the @ sign and no spaces" in errors["email"]
    end

    test "updates another user's email if lower admin level", %{conn: conn, user: user} do
      admin = PetStore.AccountsFixtures.user_fixture(admin_level: 2)
      conn = log_in_user(conn, admin)

      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "target" => user.email,
          "value" => unique_user_email()
        })

      assert json_response(conn, 200)["message"] =~
               "A link to confirm your email"

      assert {:ok, _} = Accounts.fetch_user_by_email(user.email)
    end

    test "does not update user email without enough permissions", %{conn: conn, user: user} do
      normal_user = PetStore.AccountsFixtures.user_fixture(admin_level: 0)
      conn = log_in_user(conn, normal_user)

      conn =
        put(conn, ~p"/users/settings", %{
          "action" => "update_email",
          "target" => user.email,
          "value" => unique_user_email()
        })

      assert json_response(conn, 403)
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

      assert {:error, :not_found} == Accounts.fetch_user_by_email(user.email)
      assert {:ok, _} = Accounts.fetch_user_by_email(email)

      conn =
        build_conn()
        |> Plug.Conn.put_req_header("authorization", "Bearer #{user_token}")
        |> get(~p"/users/settings/confirm_email/#{token}")

      assert json_response(conn, 404)
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/settings/confirm_email/oops")

      assert json_response(conn, 404)

      assert {:ok, _} = Accounts.fetch_user_by_email(user.email)
    end

    test "fails if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      %{status: status} = conn
      assert status == 401
    end
  end
end
