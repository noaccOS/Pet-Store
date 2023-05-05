defmodule PetStoreWeb.UserConfirmationControllerTest do
  use PetStoreWeb.ConnCase, async: true

  alias PetStore.Accounts
  alias PetStore.Repo
  import PetStore.AccountsFixtures
  require IEx

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, user: user} do
      post(conn, ~p"/users/confirm", %{
        "user" => %{"email" => user.email}
      })

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if User is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      post(conn, ~p"/users/confirm", %{
        "user" => %{"email" => user.email}
      })

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      post(conn, ~p"/users/confirm", %{
        "user" => %{"email" => "unknown@example.com"}
      })

      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "POST /users/confirm/:token" do
    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = post(conn, ~p"/users/confirm/#{token}")

      user = Accounts.fetch_user!(user.id)

      assert user.confirmed_at
      refute conn.assigns[:user_token]
      assert Repo.all(Accounts.UserToken) == []

      # When not logged in
      conn = post(conn, ~p"/users/confirm/#{token}")
      assert json_response(conn, 404)

      # When logged in
      conn =
        build_conn()
        |> log_in_user(user)
        |> post(~p"/users/confirm/#{token}")

      assert json_response(conn, 200)
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/users/confirm/oops")

      assert json_response(conn, 404)
      refute Accounts.fetch_user!(user.id).confirmed_at
    end
  end
end
