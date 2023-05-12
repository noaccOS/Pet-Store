defmodule PetStore.Repo do
  use Ecto.Repo,
    otp_app: :pet_store,
    adapter: Ecto.Adapters.Postgres

  def fetch(resource, id, opts \\ []) do
    case get(resource, id, opts) do
      nil -> {:error, :not_found}
      x -> {:ok, x}
    end
  end

  def fetch_by(resource, attrs, opts \\ []) do
    case get_by(resource, attrs, opts) do
      nil -> {:error, :not_found}
      x -> {:ok, x}
    end
  end

  def fetch!(resource, id, opts \\ []) do
    get!(resource, id, opts)
  end

  def fetch_by!(resource, attrs, opts \\ []) do
    get_by!(resource, attrs, opts)
  end
end
