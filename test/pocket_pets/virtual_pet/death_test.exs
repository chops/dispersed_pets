defmodule PocketPets.VirtualPet.DeathTest do
  use ExUnit.Case, async: true

  alias PocketPets.VirtualPet.Nursery
  alias PocketPets.VirtualPet.Pet

  defp tick_until_dead(pet, limit \\ 300) do
    Enum.reduce_while(1..limit, {0, pet}, fn i, {_n, p} ->
      p = Pet.tick(p)
      if Pet.dead?(p), do: {:halt, {i, p}}, else: {:cont, {i, p}}
    end)
  end

  test "a neglected pet dies inside a demo-sized window" do
    {ticks, dead} = tick_until_dead(Pet.new_pet(:noodle))

    assert Pet.dead?(dead)
    assert Pet.mood(dead) == :dead

    # Death has to be reachable while an audience is watching, or the dead
    # counter never moves. At a 2s tick this is roughly 60-120 seconds.
    assert ticks in 30..60
  end

  test "a dead pet ignores every action" do
    {_ticks, dead} = tick_until_dead(Pet.new_pet(:noodle))

    frozen = dead |> Pet.feed() |> Pet.play() |> Pet.nap() |> Pet.tick()

    assert frozen.state == dead.state
  end

  test "attentive care keeps a pet alive indefinitely" do
    pet =
      Enum.reduce(1..300, Pet.new_pet(:byte), fn i, p ->
        p = Pet.tick(p)
        p = if rem(i, 2) == 0, do: Pet.feed(p), else: p
        if rem(i, 6) == 0, do: p |> Pet.play() |> Pet.nap(), else: p
      end)

    assert Pet.alive?(pet)
    assert pet.state.neglect == 0
  end

  test "playing without feeding starves the pet, because play and nap add hunger" do
    {ticks, pet} =
      Enum.reduce_while(1..300, {0, Pet.new_pet(:miso)}, fn i, {_n, p} ->
        p = Pet.tick(p)
        p = if rem(i, 3) == 0, do: p |> Pet.play() |> Pet.nap(), else: p
        if Pet.dead?(p), do: {:halt, {i, p}}, else: {:cont, {i, p}}
      end)

    assert Pet.dead?(pet)
    assert pet.state.hunger == 100
    assert ticks < 60
  end

  test "revive returns a fresh pet of the same character" do
    {_ticks, dead} = tick_until_dead(Pet.new_pet(:noodle))

    revived = Pet.revive(dead)

    assert Pet.alive?(revived)
    assert revived.state.pet_key == dead.state.pet_key
    assert revived.state.pet_name == dead.state.pet_name
    assert revived.state.age_ticks == 0
    assert revived.state.neglect == 0
  end

  test "nursery tallies deaths cumulatively and broadcasts them" do
    Nursery.subscribe()
    %{dead: before} = Nursery.stats()

    Nursery.record_death(:noodle)
    assert_receive {:pet_stats, %{dead: first}}, 1_000

    Nursery.record_death(:byte)
    assert_receive {:pet_stats, %{dead: second, by_pet: by_pet}}, 1_000

    assert first == before + 1
    assert second == before + 2
    assert by_pet[:noodle] >= 1
    assert by_pet[:byte] >= 1
  end
end
