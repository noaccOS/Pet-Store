defmodule PetStoreWeb.UserSettingsJSON do
  use PetStoreWeb, :json

  def re_login(%{msg: msg, token: token}) do
    %{
      status: "ok",
      message: msg,
      token: token
    }
  end
end
