defmodule PocketPets.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PocketPetsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:pocket_pets, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PocketPets.PubSub},
      PocketPetsWeb.Presence,
      PocketPets.Jido,
      PocketPets.VirtualPet.Nursery,
      fleet_demo_child(),
      # Start a worker by calling: PocketPets.Worker.start_link(arg)
      # {PocketPets.Worker, arg},
      # Start to serve requests, typically the last entry
      PocketPetsWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PocketPets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp fleet_demo_child do
    if System.get_env("FLEET_DEMO") in ["1", "true", "yes"] do
      PocketPets.FleetDemo
    else
      %{
        id: :fleet_demo_disabled,
        start: {Task, :start_link, [fn -> :ok end]},
        restart: :temporary
      }
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PocketPetsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
