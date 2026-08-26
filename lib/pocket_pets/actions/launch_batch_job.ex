defmodule PocketPets.Actions.LaunchBatchJob do
  @moduledoc """
  Launches a finite Docker BATCH job on Dispersed.
  """

  use Jido.Action,
    name: "launch_batch_job",
    description: "Launch a finite Docker BATCH job on Dispersed.",
    schema: [
      image: [type: :string, required: true],
      tag: [type: :string, default: "latest"],
      title: [type: :string, default: "Jido Fleet Worker"],
      max_timeout_run_ms: [type: :integer, default: 600_000],
      gpu_count: [type: :integer, default: 1],
      min_vram_gb: [type: :integer, default: 8],
      dry_run: [type: :boolean, default: true]
    ]

  alias PocketPets.Dispersed.Client

  @impl true
  def run(params, _context) do
    body =
      params
      |> Map.take([:image, :tag, :title, :max_timeout_run_ms, :gpu_count, :min_vram_gb])
      |> Map.put_new(:cpu_count, 2)
      |> Map.put_new(:min_ram_gb, 16)
      |> Map.put_new(:min_storage_gb, 32)
      |> Client.batch_job()

    if params.dry_run do
      {:ok, %{status: :dry_run, job: body}}
    else
      case Client.create_job(body) do
        {:ok, %{status: status, body: response}} when status in 200..299 ->
          {:ok, %{status: :launched, response: response}}

        {:ok, response} ->
          {:error, %{status: response.status, body: response.body}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
