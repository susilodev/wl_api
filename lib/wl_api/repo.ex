defmodule WlApi.Repo do
  use Ecto.Repo,
    otp_app: :wl_api,
    adapter: Ecto.Adapters.Postgres
end
