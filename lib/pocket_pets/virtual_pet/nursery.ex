defmodule PocketPets.VirtualPet.Nursery do
  @moduledoc """
  Tracks a cumulative tally of pets that have died on this node.

  Deliberately *not* derived from `Phoenix.Presence`. Presence tracks live
  connections, so a death would stop being counted the moment the visitor
  closed their tab. "14 pets have died tonight" is the stat worth showing on
  the splash screen; "3 currently-open tabs contain a dead pet" is not.

  Alive counts stay with Presence (see `PocketPetsWeb.Presence`), which
  already handles disconnects correctly.
  """

  use GenServer

  @topic "pets:stats"

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc "Topic that `{:pet_stats, stats}` messages are broadcast on."
  def topic, do: @topic

  @doc """
  Record one death and broadcast the updated tally.

  Safe to call from a LiveView on an `:alive -> :dead` transition; it is a cast,
  so a slow or restarting Nursery never blocks a render.
  """
  def record_death(pet_key \\ nil) do
    GenServer.cast(__MODULE__, {:record_death, pet_key})
  end

  @doc "Current tally: `%{dead: non_neg_integer(), by_pet: %{atom() => non_neg_integer()}}`."
  def stats do
    GenServer.call(__MODULE__, :stats)
  catch
    :exit, _ -> empty_stats()
  end

  @doc "Subscribe the calling process to `{:pet_stats, stats}` broadcasts."
  def subscribe do
    Phoenix.PubSub.subscribe(PocketPets.PubSub, @topic)
  end

  # Server

  @impl true
  def init(:ok), do: {:ok, empty_stats()}

  @impl true
  def handle_cast({:record_death, pet_key}, state) do
    state =
      state
      |> Map.update!(:dead, &(&1 + 1))
      |> update_in([:by_pet, Access.key(pet_key, 0)], &(&1 + 1))

    Phoenix.PubSub.broadcast(PocketPets.PubSub, @topic, {:pet_stats, state})

    {:noreply, state}
  end

  @impl true
  def handle_call(:stats, _from, state), do: {:reply, state, state}

  defp empty_stats, do: %{dead: 0, by_pet: %{}}
end
