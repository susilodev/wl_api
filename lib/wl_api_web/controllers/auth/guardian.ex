defmodule WlApiWeb.Auth.Guardian do
  use Guardian, otp_app: :wl_api

  # Fungsi untuk encode subjek JWT (misalnya user_id)
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  # Fungsi untuk decode subjek dari token
  def resource_from_claims(%{"sub" => id}) do
    case WlApi.Repo.get(WlApi.Accounts.User, id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
