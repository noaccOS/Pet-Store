defmodule PetStoreWeb.UserAuth do
  use PetStoreWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  require IEx
  alias PetStore.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_auth_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in, by inserting a new token in the database
  and by saving the user informations in the assigns.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_token(user)

    conn
    |> log_out_user()
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  @doc """
  Logs the user out, deleting its token.
  """
  def log_out_user(conn) do
    token = conn.assigns[:user_token]

    if token && Accounts.delete_user_token(token) do
      update_in(conn.assigns, &Map.drop(&1, [:user_token, :current_user]))
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> resp(401, "Unauthorized")
      |> send_resp()
      |> halt()
    end
  end

  def load_user_from_auth(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      user = Accounts.get_user_by_token(token)

      conn
      |> assign(:current_user, user)
      |> assign(:user_token, token)
    else
      _ -> conn
    end
  end
end
