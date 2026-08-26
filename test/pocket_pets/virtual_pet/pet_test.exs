defmodule PocketPets.VirtualPet.PetTest do
  use ExUnit.Case, async: true

  alias PocketPets.VirtualPet
  alias PocketPets.VirtualPet.Pet

  test "tick visibly decays stats for a demo window" do
    pet =
      :noodle
      |> Pet.new_pet()
      |> Pet.tick()

    assert pet.state.hunger == 46
    assert pet.state.happiness == 71
    assert pet.state.energy == 66
    assert pet.state.age_ticks == 1
  end

  test "feed, play, and nap update the same immutable Jido agent" do
    pet =
      :noodle
      |> Pet.new_pet()
      |> Pet.feed()
      |> Pet.play()
      |> Pet.nap()

    assert pet.state.hunger == 28
    assert pet.state.happiness == 100
    assert pet.state.energy == 93
    assert pet.state.last_event == :nap
  end

  test "jido_character expression backs the pet line" do
    pet = Pet.new_pet(:byte)

    assert VirtualPet.Characters.get(:byte).character.voice.expressions != []
    assert Pet.line(pet) =~ "Byte"
  end
end
