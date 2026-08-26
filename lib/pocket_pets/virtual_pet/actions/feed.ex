defmodule PocketPets.VirtualPet.Actions.Feed do
  @moduledoc "Feeds the virtual pet."

  use Jido.Action,
    name: "pet_feed",
    description: "Lower hunger and add a little happiness.",
    schema: []

  alias PocketPets.VirtualPet.Pet

  @impl true
  def run(_params, %{state: state}) do
    {:ok,
     %{
       hunger: Pet.clamp(state.hunger - 30),
       happiness: Pet.clamp(state.happiness + 8),
       last_event: :feed
     }}
  end
end
