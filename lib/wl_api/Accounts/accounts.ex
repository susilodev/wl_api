defmodule WlApi.Accounts do
  import Ecto.Query, warn: false
  alias WlApi.Repo
  alias WlApi.Accounts.User
  alias WlApiWeb.Auth.Guardian
  alias WlApi.Mailer.Mailer
  alias WlApi.Mailer.Email

  @doc """
   Create new user as params json,
   create_user(attrs)

   ## Params
   attrs = %{
       username (String)
       email <String)
       password_hash (String)
     }

   ## Return Values
    - `{:ok, %{user: User.t(), token: String.t(), email: atom()}}`: if success
    - `{:error, :user, Ecto.Changeset.t(), map()}`: if user fail
    - `{:error, :token, Ecto.Changeset.t(), map()}`: if generate_confirmation_token() fail
    - `{:error, :email, Ecto.Changeset.t(), map()}`: if email_confirmation_register fail
    - `{:error, any()}`: Unexpected error

  """
  @spec create_user(map()) ::
          {:ok, %{user: User.t(), token: String.t(), email: atom()}}
          | {:error, :user, Ecto.Changeset.t(), map()}
          | {:error, :token, Ecto.Changeset.t(), map()}
          | {:error, :email, Ecto.Changeset.t(), map()}
          | {:error, any()}

  def create_user(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Ecto.Multi.run(:token, fn _repo, %{user: user} ->
      case generate_confirmation_token(user) do
        {:ok, token} -> {:ok, token}
        {:error, reason} -> {:error, reason}
      end
    end)
    |> Ecto.Multi.run(:email, fn _repo, %{user: user, token: token} ->
      case Mailer.deliver(Email.registration_confirmation(user, token)) do
        {:ok, _result} -> {:ok, :sent}
        {:error, reason} -> {:error, reason}
      end
    end)
    |> Repo.transaction()
  end

  # Generate token confirmation for registration/ confirmation email
  def generate_confirmation_token(user) do
    expiration = Timex.now() |> Timex.add(Timex.Duration.from_hours(24)) |> Timex.to_unix()
    claims = %{"type" => "email_confirmation_register", "exp" => expiration}

    case Guardian.encode_and_sign(user, claims) do
      {:ok, token, _claims} ->
        {:ok, token}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def activate_user(user_id) do
    case Repo.get(User, user_id) do
      nil ->
        {:error, "User not found"}

      %User{} = user ->
        user
        |> User.changeset(%{status: "active"})
        |> Repo.update()
    end
  end
end
