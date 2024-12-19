defmodule WlApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @doc """

    status "real" | "active" | "nil" | "deactive"

  """
  @derive {Jason.Encoder, only: [:id, :username, :email, :status]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :status, :string, default: "nil"
    timestamps()
  end

  @required_fields [:username, :email, :password_hash]

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash, :status])
    |> validate_required(@required_fields)
    |> validate_length(:username, min: 3, message: "minimum 3 char")
    |> validate_length(:username, max: 20, message: "maximum 20 char")
    |> validate_username(:username)
    |> unique_constraint(:username)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password_hash, min: 10)
    |> put_pass_hash()
  end

  defp validate_username(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      cond do
        value =~ ~r/^[0-9]/ -> [{field, "Not able starts with number"}]
        value =~ ~r/^[a-zA-Z0-9_]+$/ -> []
        true -> [{field, "only allowed alphabetical, number, and underscore"}]
      end
    end)
  end

  defp put_pass_hash(changeset) do
    case get_change(changeset, :password_hash) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
