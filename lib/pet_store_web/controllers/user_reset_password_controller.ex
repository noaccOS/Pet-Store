defmodule PetStoreWeb.UserResetPasswordController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts

  action_fallback PetStoreWeb.FallbackController

  def create(conn, %{"user" => %{"email" => email}}) do
    with {:ok, user} <- Accounts.fetch_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &"POST #{url(~p[/users/reset_password/#{&1}])}"
      )
    end

    render(
      conn,
      :message_ok,
      msg:
        "If your email is in our system, " <>
          "you will receive instructions to reset your password shortly."
    )
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"user" => user_params}) do
    %{"token" => token} = conn.params

    with {:ok, orig_user} <- Accounts.fetch_user_by_reset_password_token(token),
         {:ok, user} <- Accounts.reset_user_password(orig_user, user_params) do
      render(conn, :data, data: user)
    end
  end
end
