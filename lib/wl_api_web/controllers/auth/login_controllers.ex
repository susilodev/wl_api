defmodule WlApiWeb.Auth.LoginControllers do
  use WlApiWeb, :controller
  action_fallback(WlApiWeb.FallbackController)

  def login(conn, %{"username" => username, "email" => email, "password_hash" => password_hash}) do
  end
end
