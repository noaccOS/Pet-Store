defmodule PetStoreWeb.UserSettingsController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth

  plug :assign_email_and_password_changesets

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user
    token = conn.assigns.user_token

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &"""
          GET #{url(~p[/users/settings/confirm_email/#{&1}])}
          Authorization: Bearer #{token}
          """
        )

        render(
          conn,
          :message_ok,
          msg: "A link to confirm your email change has been sent to the new address."
        )

      {:error, _changeset} ->
        render(conn, :message_error, msg: "There has been an error trying to change the email.")
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn = UserAuth.log_in_user(conn, user)
        token = conn.assigns.user_token
        render(conn, :re_login, msg: "Password updated successfully.", token: token)

      {:error, _changeset} ->
        render(conn, :message_error, msg: "Error. Password not updated")
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        render(conn, :message_ok, msg: "Email changed successfully.")

      :error ->
        render(conn, :message_error, msg: "Email change link is invalid or it has expired.")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end
end
