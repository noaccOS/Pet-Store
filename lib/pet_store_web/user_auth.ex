defmodule PetStoreWeb.UserAuth do
  use PetStoreWeb, :verified_routes

  import Plug.Conn

  alias PetStore.Accounts

  @doc """
  Logs the user in, by inserting a new token in the database
  and by saving the user informations in the assigns.
  """
  def log_in_user(conn, user, _params \\ %{}) do
    token = Accounts.generate_user_token(user)

    conn
    |> log_out_user()
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  @doc """
  Logs the user out, deleting its token.
  """
  def log_out_user(conn) do
    token = conn.assigns[:user_token]

    token && Accounts.delete_user_token(token)
    update_in(conn.assigns, &Map.drop(&1, [:user_token, :current_user]))
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    case try_authenticate(conn) do
      {:ok, token, user} ->
        insert_auth(conn, token, user)

      {:error, status} ->
        raise_error(conn, status)
    end
  end

  def maybe_authenticate_user(conn, _opts) do
    case try_authenticate(conn) do
      {:ok, token, user} -> insert_auth(conn, token, user)
      _ -> conn
    end
  end

  def require_admin(conn, _opts) do
    case try_authenticate(conn) do
      {:ok, token, user} when user.admin_level > 0 ->
        insert_auth(conn, token, user)

      {:error, status} ->
        raise_error(conn, status)

      _ ->
        raise_error(conn, :forbidden)
    end
  end

  @doc """
  Plug which only allows connections where the requested user is the same as the logged in user
  or the logged in user has higher admin rights
  """
  def same_user_or_higher_admin(conn, _opts) do
    caller_id = get_in(conn.assigns, [:current_user, Access.key!(:id)])

    requested_id =
      get_in(conn.path_params, [Access.key("id", "")])
      |> Integer.parse()
      |> case do
        :error -> nil
        {id, ""} -> id
      end

    if caller_id && requested_id &&
         (same_user(caller_id, requested_id) or
            higher_admin(conn.assigns.current_user.admin_level, requested_id)),
       do: conn,
       else: raise_error(conn, :forbidden)
  end

  defp same_user(x, y), do: x == y

  defp higher_admin(caller_level, requested_id) do
    case Accounts.fetch_user(requested_id) do
      {:ok, user} -> caller_level > user.admin_level
      _ -> false
    end
  end

  defp raise_error(conn, status, body \\ "") do
    conn
    |> resp(status, body)
    |> send_resp()
    |> halt()
  end

  defp insert_auth(conn, token, user) do
    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  defp try_authenticate(conn) do
    with {:ok, token} <- load_token_from_auth(get_req_header(conn, "authorization")),
         {:ok, user} <- load_user_by_token(token) do
      {:ok, token, user}
    end
  end

  defp load_token_from_auth(["Bearer " <> token]), do: {:ok, token}
  defp load_token_from_auth([]), do: {:error, :unauthorized}
  defp load_token_from_auth(_), do: {:error, :bad_request}

  defp load_user_by_token(token) do
    case Accounts.fetch_user_by_token(token) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :forbidden}
    end
  end
end
