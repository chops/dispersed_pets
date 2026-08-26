defmodule PocketPets.Dispersed.Client do
  @moduledoc """
  Minimal Dispersed API client for launching Docker jobs.
  """

  alias PocketPets.Dispersed.Auth

  @base_url "https://api.dispersed.com"

  def batch_job(params) do
    timeout_ms = Map.fetch!(params, :max_timeout_run_ms)

    params
    |> job_base()
    |> Map.merge(%{
      task: "BATCH",
      max_timeout_run_ms: timeout_ms
    })
  end

  def persistent_job(params) do
    params
    |> job_base()
    |> Map.merge(%{
      task: "PERSISTENT",
      max_timeout_run_ms: nil
    })
  end

  def create_job(body, opts \\ []) do
    path = "/v1/jobs"
    base_url = Keyword.get(opts, :base_url, System.get_env("DISPERSED_API_BASE_URL", @base_url))

    auth_opts = [
      public_key: Keyword.get(opts, :public_key, System.fetch_env!("DISPERSED_PUBLIC_KEY")),
      secret_key: Keyword.get(opts, :secret_key, System.fetch_env!("DISPERSED_SECRET_KEY"))
    ]

    headers = Auth.headers("POST", path, %{}, body, auth_opts)

    Req.post(base_url <> path,
      body: Auth.canonical_body(body),
      headers: headers,
      receive_timeout: 30_000
    )
  end

  defp job_base(params) do
    %{
      title: Map.get(params, :title, "Jido Fleet Worker"),
      cpu_count: Map.get(params, :cpu_count, 1),
      gpu_count: Map.get(params, :gpu_count, 0),
      min_ram_gb: Map.get(params, :min_ram_gb, 2),
      min_storage_gb: Map.get(params, :min_storage_gb, 8),
      min_vram_gb: Map.get(params, :min_vram_gb, 0),
      parameters: %{
        type: "docker",
        parameters: %{
          image: Map.fetch!(params, :image),
          tag: Map.get(params, :tag, "latest")
        }
      }
    }
  end
end
