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

  @doc """
  A small wrapper around `Repo.transaction/2'.

  Commits the transaction if the lambda returns `{:ok, result}`, rolling it
  back if the lambda returns `{:error, reason}`. In both cases, the function
  returns the result of the lambda.
  """
  @spec transact((() -> any()), keyword()) :: {:ok, any()} | {:error, any()}
  def transact(fun, opts \\ []) do
    transaction(
      fn ->
        case fun.() do
          {:ok, value} -> value
          :ok -> :transaction_commited
          {:error, reason} -> rollback(reason)
          :error -> rollback(:transaction_rollback_error)
        end
      end,
      opts
    )
  end
end
