defmodule PetStoreWeb.UserSessionJSON do
  use PetStoreWeb, :json

  def login(%{token: token}) do
    %{
      status: "ok",
      token: token
    }
  end
end
