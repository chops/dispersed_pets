defmodule PocketPets.Actions.BuildDeployPlan do
  @moduledoc """
  Builds a practical Dispersed deployment plan for a hackathon-sized agent idea.
  """

  use Jido.Action,
    name: "build_deploy_plan",
    description: "Choose a Dispersed job shape and deployment checklist for an agent idea.",
    schema: [
      idea: [type: :string, required: true],
      interface: [type: {:in, ["web", "api", "batch", "ssh"]}, default: "web"],
      needs_gpu: [type: :boolean, default: false],
      time_budget_minutes: [type: :integer, default: 40]
    ]

  @impl true
  def run(params, _context) do
    job_type = job_type(params)
    image_name = "ghcr.io/chops/pocket_pets:latest"

    {:ok,
     %{
       idea: params.idea,
       job_type: job_type,
       title: title(params.idea),
       docker_image: image_name,
       hardware: hardware(params),
       environment: environment(params, job_type),
       dispersed_job_parameters: job_parameters(image_name, job_type, params),
       build_steps: build_steps(image_name),
       deploy_steps: deploy_steps(job_type),
       risks: risks(params, job_type),
       demo_script: demo_script(params, job_type)
     }}
  end

  defp job_type(%{interface: "batch"}), do: "BATCH"
  defp job_type(_params), do: "PERSISTENT"

  defp title(idea) do
    idea
    |> String.trim()
    |> String.slice(0, 64)
  end

  defp hardware(%{needs_gpu: true}) do
    %{
      cpu_count: 2,
      gpu_count: 1,
      min_ram_gb: 16,
      min_storage_gb: 32,
      min_vram_gb: 8
    }
  end

  defp hardware(_params) do
    %{
      cpu_count: 1,
      gpu_count: 0,
      min_ram_gb: 2,
      min_storage_gb: 8,
      min_vram_gb: 0
    }
  end

  defp environment(_params, "PERSISTENT") do
    %{
      "PHX_SERVER" => "true",
      "PORT" => "4000",
      "PHX_HOST" => "localhost",
      "SECRET_KEY_BASE" => "generate with: mix phx.gen.secret"
    }
  end

  defp environment(_params, "BATCH") do
    %{
      "MIX_ENV" => "prod",
      "SECRET_KEY_BASE" => "generate with: mix phx.gen.secret"
    }
  end

  defp job_parameters(image_name, "PERSISTENT", params) do
    hardware = hardware(params)

    Map.merge(hardware, %{
      task: "PERSISTENT",
      max_timeout_run_ms: nil,
      parameters: %{
        type: "docker",
        parameters: %{
          image: image_name,
          tag: "latest",
          allowed_ips: ["0.0.0.0/0"],
          env: environment(params, "PERSISTENT"),
          ports: [4000]
        }
      }
    })
  end

  defp job_parameters(image_name, "BATCH", params) do
    hardware = hardware(params)

    Map.merge(hardware, %{
      task: "BATCH",
      max_timeout_run_ms: params.time_budget_minutes * 60_000,
      parameters: %{
        type: "docker",
        parameters: %{
          image: image_name,
          tag: "latest",
          env: environment(params, "BATCH")
        }
      }
    })
  end

  defp build_steps(image_name) do
    [
      "mix setup",
      "mix precommit",
      "docker build -t #{image_name} .",
      "docker push #{image_name}"
    ]
  end

  defp deploy_steps("PERSISTENT") do
    [
      "Open Dispersed Console and create a direct Docker job or fork a recipe.",
      "Use task=PERSISTENT and max_timeout_run_ms=null.",
      "Set Docker parameters.env with PORT=4000, PHX_SERVER=true, PHX_HOST to the assigned host if required, and SECRET_KEY_BASE.",
      "Set Docker parameters.ports=[4000] and use the Node URLs section for the public HTTP URL.",
      "Stop the job immediately after the demo to avoid continued hourly billing."
    ]
  end

  defp deploy_steps("BATCH") do
    [
      "Open Dispersed Console and create a direct Docker job.",
      "Use task=BATCH with a timeout slightly above the expected runtime.",
      "Let the container exit cleanly when the job finishes.",
      "Use the console job logs as the demo artifact."
    ]
  end

  defp risks(%{needs_gpu: true}, _job_type) do
    [
      "GPU image size can dominate startup time; raise max_timeout_start_ms if the console exposes it.",
      "Do not rely on local Docker verification until Docker is installed on this machine.",
      "Have a CPU fallback demo path in case GPU node assignment is slow."
    ]
  end

  defp risks(_params, "PERSISTENT") do
    [
      "Persistent jobs bill until stopped.",
      "Phoenix requires SECRET_KEY_BASE in production.",
      "External LLM providers need API keys injected as environment variables."
    ]
  end

  defp risks(_params, _job_type) do
    [
      "Batch jobs are non-interactive, so the demo output must go to logs or a saved artifact.",
      "Keep image size small to avoid startup timeout."
    ]
  end

  defp demo_script(params, job_type) do
    [
      "In one sentence: #{params.idea}",
      "Show that the Jido action chose #{job_type} and generated concrete Docker/job parameters.",
      "Point out the risk list so the demo looks operationally grounded.",
      "End by showing the same app running from a Dispersed Docker job."
    ]
  end
end
