defmodule PetStoreWeb.UserAuthTest do
  use PetStoreWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth
  import PetStore.AccountsFixtures

  @remember_me_cookie "_testphx_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PetStoreWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "log_in_user/3" do
    test "stores the user token in the session", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)
      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Accounts.get_user_by_session_token(token)
    end
  end

  describe "logout_user/1" do
    test "works even if user is already logged out", %{user: user} do
      token = Accounts.generate_user_token(user)
      UserAuth.log_out_user(token)
      refute Accounts.get_user_by_token(token)
      assert UserAuth.log_out_user(token)
    end
  end

  describe "require_authenticated_user/2" do
    test "halts if user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted
      assert conn.status == 401
    end

    test "does not halt if user is authenticated", %{conn: conn, user: user} do
      token = Accounts.generate_user_token(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> UserAuth.require_authenticated_user([])

      refute conn.halted
      refute conn.status
    end
  end
end
