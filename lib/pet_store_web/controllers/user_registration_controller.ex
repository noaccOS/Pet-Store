defmodule PetStoreWeb.UserRegistrationController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStore.Accounts.User
  alias PetStoreWeb.UserAuth

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &"POST #{url(~p[/users/confirm/#{&1}])}"
          )

        conn = UserAuth.log_in_user(conn, user)
        token = conn.assigns.user_token
        render(conn, :register, token: token)

      {:error, _} ->
        render(conn, :message_error, msg: "Error during user creation. Please try again.")
    end
  end
end
