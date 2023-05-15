defmodule PetStoreWeb.Router do
  use PetStoreWeb, :router

  import PetStoreWeb.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PetStoreWeb do
    pipe_through [:api, :maybe_authenticate_user]

    post "/users/register", UserRegistrationController, :create
  end

  scope "/", PetStoreWeb do
    pipe_through [:api, :require_authenticated_user]

    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/", PetStoreWeb do
    pipe_through [:api]

    post "/users/confirm", UserConfirmationController, :create
    post "/users/confirm/:token", UserConfirmationController, :update

    post "/users/log_in", UserSessionController, :create
    post "/users/reset_password", UserResetPasswordController, :create
    put "/users/reset_password/:token", UserResetPasswordController, :update

    get "/pets", PetController, :index
    get "/pets/:id", PetController, :show
  end

  scope "/", PetStoreWeb do
    pipe_through [:api, :require_admin]

    post "/pets", PetController, :create
    patch "/pets/:id", PetController, :update
    put "/pets/:id", PetController, :update
    delete "/pets/:id", PetController, :delete

    get "/carts", CartController, :index
    get "/carts/:id", CartController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pet_store, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PetStoreWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
