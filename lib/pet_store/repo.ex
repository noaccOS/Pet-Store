defmodule PetStore.Repo do
  use Ecto.Repo,
    otp_app: :pet_store,
    adapter: Ecto.Adapters.Postgres
end
