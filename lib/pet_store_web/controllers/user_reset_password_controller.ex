defmodule PetStoreWeb.UserResetPasswordController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts

  plug :get_user_by_reset_password_token when action == :update

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
    case Accounts.reset_user_password(conn.assigns.user, user_params) do
      {:ok, _} ->
        render(conn, :message_ok, msg: "Password reset successfully.")

      {:error, _changeset} ->
        render(conn, :message_error, msg: "Error encountered during password reset.")
    end
  end

  defp get_user_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    case Accounts.fetch_user_by_reset_password_token(token) do
      {:ok, user} ->
        conn |> assign(:user, user) |> assign(:token, token)

      :error ->
        render(conn, :message_error, msg: "Reset password link is invalid or it has expired.")
    end
  end
end
