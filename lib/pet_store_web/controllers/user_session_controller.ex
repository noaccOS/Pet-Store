defmodule PetStoreWeb.UserSessionController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn = UserAuth.log_in_user(conn, user, user_params)
      token = conn.assigns.user_token
      render(conn, :login, token: token)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :message_error, msg: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> UserAuth.log_out_user()
    |> render(:message_ok, msg: "User logged out successfully.")
  end
end
