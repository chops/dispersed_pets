defmodule PocketPets.VirtualPet.Script do
  @moduledoc """
  Lightweight script fallback for the virtual pet demo.
  """

  alias PocketPets.VirtualPet.Pet

  def demo do
    {:ok, _apps} = Application.ensure_all_started(:jido_action)

    :noodle
    |> Pet.new_pet()
    |> print("wakes up on a Dispersed node")
    |> Pet.tick()
    |> print("notices time moving very quickly")
    |> Pet.feed()
    |> print("gets fed")
    |> Pet.play()
    |> print("plays a tiny lightning round")
    |> Pet.nap()
    |> print("takes a tactical nap")
  end

  defp print(pet, event) do
    state = pet.state

    IO.puts(
      "#{state.pet_name} #{Pet.emoji(pet)} #{event}: hunger=#{state.hunger} energy=#{state.energy} joy=#{state.happiness} mood=#{Pet.mood(pet)}"
    )

    IO.puts("#{state.pet_name}: #{Pet.line(pet)}")
    pet
  end
end
