defmodule WlApiWeb.FallbackController do
  use WlApiWeb, :controller

  # Untuk menangani kesalahan yang dikembalikan oleh controller, seperti {:error, :not_found}
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Resource not found"})
  end

  # Untuk menangani kesalahan validasi, seperti {:error, changeset}
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error: "Validation failed",
      details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    })
  end

  # Untuk menangani kesalahan internal lainnya
  def call(conn, {:error, :internal_server_error}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "Internal server error"})
  end

  # Fallback untuk kesalahan yang tidak dikenal
  def call(conn, _reason) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: "An unexpected error occurred"})
  end

  # Fungsi untuk menerjemahkan kesalahan validasi
  defp translate_error({msg, _opts}) do
    # Contoh untuk mengganti pesan kesalahan default
    # atau menambahkan logika kustom
    Phoenix.Naming.humanize(msg)
  end
end
