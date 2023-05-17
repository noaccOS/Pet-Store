defmodule PetStoreWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use PetStoreWeb, :controller
      use PetStoreWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: PetStoreWeb.Layouts]

      import Plug.Conn
      import PetStoreWeb.Gettext

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PetStoreWeb.Endpoint,
        router: PetStoreWeb.Router,
        statics: PetStoreWeb.static_paths()
    end
  end

  def json do
    quote do
      def message_info(%{msg: message}) do
        %{
          "status" => "info",
          "message" => message
        }
      end

      def message_ok(%{msg: message}) do
        %{
          "status" => "ok",
          "message" => message
        }
      end

      def data(%{data: data}) do
        %{
          "data" => to_data(data)
        }
      end

      def message_error(%{msg: message}) do
        %{
          "status" => "error",
          "message" => message
        }
      end

      defp to_data(%PetStore.Accounts.User{} = user) do
        %{
          id: user.id,
          email: user.email,
          admin_level: user.admin_level
        }
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
