defmodule WlApiWeb.Router do
  use WlApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WlApiWeb do
    pipe_through :api
  end

  scope "/api/v1/auth", WlApiWeb do
    post "/register", Auth.RegisterControllers, :register
    get "/confirm-register", Auth.ConfirmRegisterControllers, :confirm_email

    post "login", Auth.LoginControllers, :login
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:wl_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
