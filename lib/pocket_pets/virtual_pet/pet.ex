defmodule PocketPets.VirtualPet.Pet do
  @moduledoc """
  Immutable Jido agent for a per-tab virtual pet.
  """

  use Jido.Agent,
    name: "virtual_pet",
    description: "A tiny Tamagotchi-style pet with fast demo-friendly stat decay.",
    schema: [
      pet_key: [type: :atom, default: :noodle],
      pet_name: [type: :string, default: "Noodle"],
      hunger: [type: :integer, default: 42],
      happiness: [type: :integer, default: 74],
      energy: [type: :integer, default: 68],
      age_ticks: [type: :integer, default: 0],
      last_event: [type: :atom, default: :wake],
      status: [type: :atom, default: :alive],
      neglect: [type: :integer, default: 0]
    ]

  alias PocketPets.VirtualPet

  @type mood :: :dead | :starving | :tired | :sad | :content

  @doc """
  Consecutive neglected ticks before a pet dies.

  Tuned for a demo, not for realism: `:starving` arrives around 10 ticks, so an
  entirely ignored pet dies at roughly 80 seconds on the 2s tick. Pets have to
  actually die while an audience is watching, or the dead counter never moves
  and the whole mechanic is invisible. Caring for a pet resets this to 0, so
  death stays recoverable right up to the moment it happens.
  """
  def death_threshold, do: 30

  def new_pet(pet_key \\ :noodle) do
    pet_key = VirtualPet.Characters.normalize_key(pet_key)
    character = VirtualPet.Characters.get(pet_key)

    new(
      state: %{
        pet_key: pet_key,
        pet_name: character.name,
        hunger: character.defaults.hunger,
        happiness: character.defaults.happiness,
        energy: character.defaults.energy,
        age_ticks: 0,
        last_event: :wake,
        status: :alive,
        neglect: 0
      }
    )
  end

  def tick(agent), do: unless_dead(agent, VirtualPet.Actions.Tick)
  def feed(agent), do: unless_dead(agent, VirtualPet.Actions.Feed)
  def play(agent), do: unless_dead(agent, VirtualPet.Actions.Play)
  def nap(agent), do: unless_dead(agent, VirtualPet.Actions.Nap)

  @doc "True once the pet has died. Dead pets ignore every action."
  def dead?(agent), do: agent.state.status == :dead

  @doc "True while the pet is still living."
  def alive?(agent), do: not dead?(agent)

  @doc """
  Start over with a fresh pet of the same character.

  The demo needs one-click recovery: if a pet dies mid-presentation, the
  presenter should not have to reload the page to keep talking.
  """
  def revive(agent), do: new_pet(agent.state.pet_key)

  defp unless_dead(agent, action) do
    if dead?(agent), do: agent, else: command(agent, action)
  end

  def command(agent, action) do
    {agent, _directives} = cmd(agent, action)
    agent
  end

  def mood(agent), do: mood_from_state(agent.state)

  def mood_from_state(%{status: :dead}), do: :dead

  def mood_from_state(%{hunger: hunger}) when hunger >= 82, do: :starving
  def mood_from_state(%{energy: energy}) when energy <= 18, do: :tired
  def mood_from_state(%{happiness: happiness}) when happiness <= 24, do: :sad
  def mood_from_state(_state), do: :content

  def emoji(agent) do
    case mood(agent) do
      :dead -> "👻"
      :starving -> "🍜"
      :tired -> "💤"
      :sad -> "🥺"
      :content -> "✨"
    end
  end

  def line(agent) do
    agent.state.pet_key
    |> VirtualPet.Characters.line(mood(agent), agent.state.last_event)
  end

  def clamp(value), do: value |> max(0) |> min(100)
end
