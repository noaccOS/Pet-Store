defmodule PetStoreWeb.UserSessionController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = UserAuth.log_in_user(user, user_params)
      render(conn, :login, token: token)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :message_error, msg: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    "Bearer " <> token = get_req_header(conn, "authentication")
    UserAuth.log_out_user(token)
    render(conn, :message_ok, msg: "User logged out successfully.")
  end
end
