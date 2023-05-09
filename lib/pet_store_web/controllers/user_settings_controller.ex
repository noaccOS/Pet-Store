defmodule PetStoreWeb.UserSettingsController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth

  plug :assign_email_and_password_changesets

  action_fallback PetStoreWeb.FallbackController

  # Updates email address for lower-admin_level accounts
  def update(conn, %{"action" => "update_email", "target" => target_email, "value" => new_email}) do
    with {:ok, target} <-
           Accounts.maybe_redacted_user_by_email(target_email, conn.assigns.current_user),
         email_changeset = Accounts.change_user_email(target, %{email: new_email}),
         {:ok, new_user} <- Ecto.Changeset.apply_action(email_changeset, :update) do
      token = Accounts.generate_user_token(target)

      Accounts.deliver_user_update_email_instructions(
        new_user,
        target.email,
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
    end
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user
    token = conn.assigns.user_token

    with {:ok, applied_user} <- Accounts.apply_user_email(user, password, user_params) do
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
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    with {:ok, user} <- Accounts.update_user_password(user, password, user_params) do
      conn = UserAuth.log_in_user(conn, user)
      token = conn.assigns.user_token
      render(conn, :re_login, msg: "Password updated successfully.", token: token)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    with :ok <- Accounts.update_user_email(conn.assigns.current_user, token) do
      render(conn, :message_ok, msg: "Email changed successfully.")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end
end
