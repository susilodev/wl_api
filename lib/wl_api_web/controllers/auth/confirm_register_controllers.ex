defmodule WlApiWeb.Auth.ConfirmRegisterControllers do
  use WlApiWeb, :controller
  alias WlApi.Accounts
  alias WlApiWeb.Auth.Guardian

  action_fallback WlApiWeb.FallbackController

  def confirm_email(conn, %{"token" => token}) do
    case Guardian.decode_and_verify(token, %{"type" => "email_confirmation_register"}) do
      {:ok, claims} ->
        user_id = claims["sub"]

        case Accounts.activate_user(user_id) do
          {:ok, user} ->
            user_data = %{
              id: user.id,
              username: user.username,
              email: user.email,
              status: user.status
            }

            json(conn, %{message: "Email confirmed successfully", data: user_data})

          {:error, reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: reason})
        end

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid or expired token"})
    end
  end
end
