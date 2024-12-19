defmodule WlApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WlApiWeb.Telemetry,
      WlApi.Repo,
      {DNSCluster, query: Application.get_env(:wl_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WlApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WlApi.Finch},
      # Start a worker by calling: WlApi.Worker.start_link(arg)
      # {WlApi.Worker, arg},
      # Start to serve requests, typically the last entry
      WlApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WlApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WlApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
