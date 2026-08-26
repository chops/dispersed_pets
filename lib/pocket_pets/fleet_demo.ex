defmodule PocketPets.FleetDemo do
  @moduledoc """
  Log-first demo loop for Dispersed environments without public web ingress.
  """

  use GenServer

  require Logger

  alias PocketPets.Actions.LaunchBatchJob

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    send(self(), :dry_run)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:dry_run, state) do
    image = System.get_env("FLEET_WORKER_IMAGE", "ghcr.io/chops/gpu-worker")

    {:ok, %{job: job}} =
      Jido.Exec.run(LaunchBatchJob, %{
        image: image,
        title: "Fleet Commander GPU Worker",
        dry_run: true
      })

    Logger.info("fleet_commander_dry_run #{Jason.encode!(job)}")
    Logger.warning("remember_to_stop_persistent_job_after_demo billing=hourly")

    Process.send_after(self(), :dry_run, :timer.minutes(1))
    {:noreply, state}
  end
end
