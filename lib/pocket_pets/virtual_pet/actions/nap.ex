defmodule PocketPets.VirtualPet.Actions.Nap do
  @moduledoc "Lets the virtual pet nap."

  use Jido.Action,
    name: "pet_nap",
    description: "Restore energy and raise hunger slightly.",
    schema: []

  alias PocketPets.VirtualPet.Pet

  @impl true
  def run(_params, %{state: state}) do
    {:ok,
     %{
       energy: Pet.clamp(state.energy + 40),
       hunger: Pet.clamp(state.hunger + 10),
       last_event: :nap
     }}
  end
end
