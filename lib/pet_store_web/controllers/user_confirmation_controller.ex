defmodule PetStoreWeb.UserConfirmationController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts

  def create(conn, %{"user" => %{"email" => email}}) do
    with {:ok, user} <- Accounts.fetch_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &"POST #{url(~p[/users/confirm/#{&1}])}"
      )
    end

    render(
      conn,
      :message_ok,
      msg:
        "If your email is in our system and it has not been confirmed yet, " <>
          "you will receive an email with instructions shortly."
    )
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        render(conn, :message_ok, msg: "User confirmed successfully.")

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            render(conn, :message_ok)

          %{} ->
            render(conn, :message_error,
              msg: "User confirmation link is invalid or it has expired."
            )
        end
    end
  end
end
