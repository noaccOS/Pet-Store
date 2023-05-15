defmodule PetStoreWeb.UserAuthTest do
  use PetStoreWeb.ConnCase, async: true

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth
  import PetStore.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PetStoreWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), admin: user_fixture(admin_level: 1), conn: conn}
  end

  describe "log_in_user/3" do
    test "stores the user token in the session", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)
      assert token = conn.assigns[:user_token]
      assert {:ok, _} = Accounts.fetch_user_by_token(token)
    end
  end

  describe "logout_user/1" do
    test "works even if user is already logged out", %{conn: conn} do
      conn = UserAuth.log_out_user(conn)
      refute conn.assigns[:current_user]
      assert UserAuth.log_out_user(conn)
    end
  end

  describe "require_authenticated_user/2" do
    test "halts if user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted
      assert conn.status == 401
    end

    test "does not halt if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> UserAuth.require_authenticated_user([])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_admin/2" do
    test "halts if user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_admin([])
      assert conn.halted
      assert conn.status == 401
    end

    test "halts if user is authenticated but is a normal user", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> UserAuth.require_admin([])
      assert conn.halted
      assert conn.status == 403
    end

    test "does not halt if user is authenticated and an admin", %{conn: conn, admin: admin} do
      conn = conn |> log_in_user(admin) |> UserAuth.require_admin([])
      refute conn.halted
      refute conn.status
    end
  end

  describe "same_user_or_higher_admin/2" do
    test "works if same user", %{conn: conn, user: user, admin: admin} do
      conn_user =
        conn
        |> log_in_user(user)
        |> put_req_query_param("id", user.id)
        |> UserAuth.same_user_or_higher_admin([])

      refute conn_user.halted
      refute conn_user.status

      conn_admin =
        conn
        |> log_in_user(admin)
        |> put_req_query_param("id", admin.id)
        |> UserAuth.same_user_or_higher_admin([])

      refute conn_admin.halted
      refute conn_admin.status
    end

    test "works if higher admin", %{conn: conn, user: user, admin: admin} do
      conn =
        conn
        |> log_in_user(admin)
        |> put_req_query_param("id", user.id)
        |> UserAuth.same_user_or_higher_admin([])

      refute conn.halted
      refute conn.status
    end

    test "halts if lower admin", %{conn: conn, user: user, admin: admin} do
      conn =
        conn
        |> log_in_user(user)
        |> put_req_query_param("id", admin.id)
        |> UserAuth.same_user_or_higher_admin([])

      assert conn.halted
      assert conn.status == 403
    end
  end
end
