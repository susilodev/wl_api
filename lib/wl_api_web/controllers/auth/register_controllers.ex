defmodule WlApiWeb.Auth.RegisterControllers do
  @moduledoc """
  RegisterControllers
  ```json
  {
    "username": "umar",
    "password": "umar2611",
    "email": "umar2611@gmail.com"
  }
  ```
  """

  use WlApiWeb, :controller
  alias WlApi.Accounts
  import Ecto.Changeset

  action_fallback(WlApiWeb.FallbackController)

  def register(conn, %{"username" => username, "email" => email, "password_hash" => password_hash}) do
    attrs = %{
      "username" => username,
      "email" => email,
      "password_hash" => password_hash
    }

    case Accounts.create_user(attrs) do
      {:ok, %{user: user}} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "success",
          data: %{
            username: user.username
          }
        })

      {:error, :email, reason, _changes} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          status: "error",
          data: %{
            error: "failed to send email",
            reason: reason
          }
        })

      {:error, :token, reason, _changes} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          status: "error",
          data: %{
            error: "failed generate confirmation token",
            reason: reason
          }
        })

      {:error, :user, changeset, _changes} ->
        errors = traverse_errors(changeset, fn {msg, _opts} -> msg end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          status: "error",
          data: %{
            error: errors,
            reason: errors
          }
        })
    end
  end

  # def register(conn, %{"username" => username, "email" => email, "password_hash" => password_hash}) do
  #   attrs = %{
  #     "username" => username,
  #     "email" => email,
  #     "password_hash" => password_hash
  #   }
  #
  #   case Accounts.create_user(attrs) do
  #     {:ok, user} ->
  #       # Buat token JWT
  #       {:ok, token, _claims} =
  #         Guardian.encode_and_sign(user, %{"type" => "email_confirmation_register"},
  #           ttl: {1, :hour}
  #         )
  #
  #       user
  #       |> Email.registration_confirmation(token)
  #       |> Mailer.deliver_email()
  #
  #       conn
  #       |> put_status(:created)
  #       |> json(%{
  #         status: "success",
  #         data: %{
  #           username: user.username
  #         }
  #       })
  #
  #     {:error, changeset} ->
  #       errors = traverse_errors(changeset, fn {msg, _opts} -> msg end)
  #
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> json(%{errors: errors})
  #   end
  # end
end
