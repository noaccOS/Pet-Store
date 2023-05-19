defmodule PetStoreWeb.Authorization do
  @behaviour Bodyguard.Policy

  alias PetStore.Accounts.User

  def authorize(:update_email, user, target) do
    same_user_or_higher_admin(target, user)
  end

  def authorize(:access_cart, user, target) do
    same_user_or_higher_admin(target, user)
  end

  ### Same user or higehr admin

  defp same_user_or_higher_admin(%User{id: id} = _target, %User{id: id} = _caller), do: :ok

  defp same_user_or_higher_admin(target, caller) do
    caller.admin_level > target.admin_level
  end
end
