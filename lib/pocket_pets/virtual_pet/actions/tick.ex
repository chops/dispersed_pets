defmodule PocketPets.VirtualPet.Actions.Tick do
  @moduledoc """
  Advances virtual pet state by one visible demo tick.

  Also accumulates neglect. A tick that leaves the pet in any distressed mood
  counts against it; a tick where it is content clears the count. Once the
  neglect run reaches `Pet.death_threshold/0`, the pet dies.
  """

  use Jido.Action,
    name: "pet_tick",
    description: "Advance hunger, happiness, energy, age, and neglect.",
    schema: []

  alias PocketPets.VirtualPet.Pet

  @impl true
  def run(_params, %{state: state}) do
    stats = %{
      hunger: Pet.clamp(state.hunger + 4),
      happiness: Pet.clamp(state.happiness - 3),
      energy: Pet.clamp(state.energy - 2)
    }

    neglect = next_neglect(stats, state.neglect)

    {:ok,
     Map.merge(stats, %{
       age_ticks: state.age_ticks + 1,
       last_event: :tick,
       neglect: neglect,
       status: status_for(neglect)
     })}
  end

  # Judged from the mood the pet is *about* to show, so what the visitor sees on
  # screen is exactly what is counting against it.
  defp next_neglect(stats, neglect) do
    case Pet.mood_from_state(Map.put(stats, :status, :alive)) do
      :content -> 0
      _distressed -> neglect + 1
    end
  end

  defp status_for(neglect) do
    if neglect >= Pet.death_threshold(), do: :dead, else: :alive
  end
end
