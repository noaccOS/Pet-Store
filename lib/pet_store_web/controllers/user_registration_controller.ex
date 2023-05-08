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

  # Do not login after creation, it was probably created for someone else
  def create_admin(conn, %{"user" => user_params}) do
    current_user = conn.assigns[:current_user]

    with {:ok, new_user} <- Accounts.register_user(user_params, current_user) do
      render(conn, :data, data: new_user)
    else
      {:error, %{"errors" => %{"admin_level" => admin}} = changeset} ->
        if "insufficient permissions" in admin,
          do: {:error, :forbidden},
          else: {:error, changeset}

      other ->
        other
    end
  end
end
