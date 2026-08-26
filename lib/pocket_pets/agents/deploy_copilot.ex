defmodule PocketPets.Agents.DeployCopilot do
  @moduledoc """
  Jido agent that plans compact Dispersed deployments for hackathon ideas.
  """

  use Jido.Agent,
    name: "deploy_copilot",
    description: "Plans Docker-backed Dispersed deployments for small Jido agent ideas.",
    schema: [
      idea: [type: :string, default: ""],
      interface: [type: :string, default: "web"],
      needs_gpu: [type: :boolean, default: false],
      time_budget_minutes: [type: :integer, default: 40],
      job_type: [type: :string, default: ""],
      title: [type: :string, default: ""],
      docker_image: [type: :string, default: ""],
      hardware: [type: :map, default: %{}],
      environment: [type: :map, default: %{}],
      dispersed_job_parameters: [type: :map, default: %{}],
      build_steps: [type: {:list, :string}, default: []],
      deploy_steps: [type: {:list, :string}, default: []],
      risks: [type: {:list, :string}, default: []],
      demo_script: [type: {:list, :string}, default: []]
    ],
    signal_routes: [
      {"deploy.plan", PocketPets.Actions.BuildDeployPlan}
    ],
    strategy:
      {Jido.Agent.Strategy.FSM,
       initial_state: "ready",
       transitions: %{
         "ready" => ["planning"],
         "planning" => ["ready"]
       },
       auto_transition: true}
end
