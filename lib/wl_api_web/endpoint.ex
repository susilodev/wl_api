defmodule WlApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :wl_api

  require Logger

  # The session will be stored in the cookie and signed
  @session_options [
    store: :cookie,
    key: "_wl_api_key",
    signing_salt: "lwwlmAP2",
    same_site: "Lax"
  ]

  plug Plug.Static,
    at: "/",
    from: :wl_api,
    gzip: false,
    only: WlApiWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :wl_api
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug WlApiWeb.Router

  plug Plug.ErrorHandler

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    Logger.error("""
    [#{kind}] #{inspect(reason)}
    """)

    # Atur respons error dengan detail minimal untuk keamanan.
    conn
    |> put_status(Phoenix.Controller.status_code_from_reason(reason))
    |> Phoenix.Controller.json(%{
      error:
        Phoenix.Controller.status_message_from_template(
          Phoenix.Controller.status_code_from_reason(reason)
        )
    })
  end
end
