defmodule PocketPets.DeployCopilot do
  @moduledoc """
  Public API for the Dispersed deployment copilot agent.
  """

  @default_params %{
    idea: "A Jido agent that helps hackathon builders deploy Docker workloads on Dispersed.",
    interface: "web",
    needs_gpu: false,
    time_budget_minutes: 40
  }

  def plan(params) when is_map(params) do
    params = normalize_params(params)

    PocketPets.Actions.BuildDeployPlan
    |> Jido.Exec.run(params)
    |> case do
      {:ok, plan} -> {:ok, public_plan(plan)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sample_ideas do
    [
      %{
        name: "Noodle",
        pitch: "A dramatic snack-driven pet whose mood swings visibly as hunger rises.",
        why:
          "Fast to understand, funny in a 60-second demo, and easy to drive with three buttons."
      },
      %{
        name: "Byte",
        pitch:
          "A focused little robot pet that prefers naps, clean routines, and precise praise.",
        why: "Contrasts well with Noodle and shows jido_character personalities clearly."
      },
      %{
        name: "Miso",
        pitch: "A playful mischief engine: needy, competitive, and always ready for a game.",
        why: "Gives the UI a livelier pet option without adding mechanics."
      },
      %{
        name: "Script fallback",
        pitch: "A `mix run ...` pet tick prints personality, stats, and a one-line quip.",
        why: "Works from Dispersed logs if public Phoenix ingress is not available."
      },
      %{
        name: "Stretch: pet council",
        pitch: "Multiple pets react to the same action with different personality text.",
        why: "A good use of jido_character if the one-pet loop is finished early."
      }
    ]
  end

  defp public_plan(state) do
    Map.take(state, [
      :idea,
      :job_type,
      :title,
      :docker_image,
      :hardware,
      :environment,
      :dispersed_job_parameters,
      :build_steps,
      :deploy_steps,
      :risks,
      :demo_script
    ])
  end

  defp normalize_params(params) do
    @default_params
    |> Map.merge(atomize_known_keys(params))
    |> Map.update!(:idea, &to_string/1)
    |> Map.update!(:interface, &normalize_interface/1)
    |> Map.update!(:needs_gpu, &truthy?/1)
    |> Map.update!(:time_budget_minutes, &normalize_minutes/1)
  end

  defp atomize_known_keys(params) do
    Enum.reduce(params, %{}, fn
      {key, value}, acc when key in [:idea, :interface, :needs_gpu, :time_budget_minutes] ->
        Map.put(acc, key, value)

      {"idea", value}, acc ->
        Map.put(acc, :idea, value)

      {"interface", value}, acc ->
        Map.put(acc, :interface, value)

      {"needs_gpu", value}, acc ->
        Map.put(acc, :needs_gpu, value)

      {"time_budget_minutes", value}, acc ->
        Map.put(acc, :time_budget_minutes, value)

      {_key, _value}, acc ->
        acc
    end)
  end

  defp normalize_interface(value) do
    value = value |> to_string() |> String.downcase()

    if value in ["web", "api", "batch", "ssh"] do
      value
    else
      "web"
    end
  end

  defp truthy?(value) when value in [true, "true", "1", 1, "yes", "on"], do: true
  defp truthy?(_value), do: false

  defp normalize_minutes(value) when is_integer(value) and value > 0, do: value

  defp normalize_minutes(value) do
    case Integer.parse(to_string(value)) do
      {minutes, ""} when minutes > 0 -> minutes
      _other -> 40
    end
  end
end
