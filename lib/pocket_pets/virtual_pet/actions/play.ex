defmodule PocketPets.VirtualPet.Actions.Play do
  @moduledoc "Plays with the virtual pet."

  use Jido.Action,
    name: "pet_play",
    description: "Increase happiness and spend energy.",
    schema: []

  alias PocketPets.VirtualPet.Pet

  @impl true
  def run(_params, %{state: state}) do
    {:ok,
     %{
       happiness: Pet.clamp(state.happiness + 25),
       energy: Pet.clamp(state.energy - 15),
       hunger: Pet.clamp(state.hunger + 6),
       last_event: :play
     }}
  end
end
