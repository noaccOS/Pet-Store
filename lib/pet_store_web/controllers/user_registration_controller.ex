defmodule PetStoreWeb.UserRegistrationController do
  use PetStoreWeb, :controller

  alias PetStore.Accounts
  alias PetStoreWeb.UserAuth

  action_fallback PetStoreWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params) do
      {:ok, _} =
        Accounts.deliver_user_confirmation_instructions(
          user,
          &"POST #{url(~p[/users/confirm/#{&1}])}"
        )

      conn = UserAuth.log_in_user(conn, user)
      token = conn.assigns.user_token
      render(conn, :register, token: token)
    end
  end
end
