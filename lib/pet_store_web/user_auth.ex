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
  Logs the user in.
  In practice, it returns a token for the requested user.
  """
  def log_in_user(conn, user, params \\ %{}) do
    Accounts.generate_user_token(user)
  end

  @doc """
  Logs the user out, deleting its token.
  """
  def log_out_user(token) do
    token && Accounts.delete_user_token(token)
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    with ["Bearer " <> token] <- conn |> get_req_header("authorization") do
      user = Accounts.get_user_by_token(token)
      assign(conn, :current_user, user)
    else
      [] -> conn |> resp(401, "Unauthorized") |> send_resp() |> halt()
      _ -> conn |> resp(400, "Bad request") |> send_resp() |> halt()
    end
  end
end
