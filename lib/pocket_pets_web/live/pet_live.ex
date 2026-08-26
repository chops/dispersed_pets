defmodule PocketPetsWeb.PetLive do
  use PocketPetsWeb, :live_view

  alias PocketPets.VirtualPet
  alias PocketPets.VirtualPet.Nursery
  alias PocketPets.VirtualPet.Pet
  alias PocketPetsWeb.Presence

  @presence_topic "pets:alive"

  @blank [
    "00000000000000000000000000000000",
    "00000000000000000000000000000000"
  ]

  @pet_sprites %{
    content: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111111000011111100000000",
      "00000001111101100110111110000000",
      "00000001111111111111111110000000",
      "00000011111111111111111111000000",
      "00000011110111111111101111000000",
      "00000011111001111110011111000000",
      "00000001111110000001111110000000",
      "00000000111111111111111100000000",
      "00000000011111111111111000000000",
      "00000000001111000011110000000000",
      "00000000011100000000111000000000",
      "00000000111000000000011100000000",
      "00000000000000000000000000000000",
      "00000000111100000000111100000000",
      "00000000000000000000000000000000"
    ],
    content_alt: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111111000011111100000000",
      "00000001111101100110111110000000",
      "00000001111111111111111110000000",
      "00000011111111111111111111000000",
      "00000011110111111111101111000000",
      "00000011111001111110011111000000",
      "00000001111110000001111110000000",
      "00000000111111111111111100000000",
      "00000000011111111111111000000000",
      "00000000000011100111000000000000",
      "00000000000111000011100000000000",
      "00000000001110000001110000000000",
      "00000000000000000000000000000000",
      "00000000111100000000111100000000",
      "00000000000000000000000000000000"
    ],
    hungry: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111111000011111100000000",
      "00000001111101100110111110000000",
      "00000001111111111111111110000000",
      "00000011111111111111111111000000",
      "00000011111110000001111111000000",
      "00000011111101111110111111000000",
      "00000001111110000001111110000000",
      "00000000111111111111111100000000",
      "00000000011111111111111000000000",
      "00000000001111111111110000000000",
      "00000000011100000000111000000000",
      "00000000111000000000011100000000",
      "00000000000000000000000000000000",
      "00000111000000000000000000000000",
      "00000111000000000000000000000000"
    ],
    tired: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111110011001111100000000",
      "00000001111111111111111110000000",
      "00000001111100000011111110000000",
      "00000011111111111111111111000000",
      "00000011110111111111101111000000",
      "00000011111001111110011111000000",
      "00000001111110000001111110000000",
      "00000000111111111111111100000000",
      "00000000011111111111111000000000",
      "00000000001111000011110000000000",
      "00000000011100000000111000000000",
      "00000000111000000000011100000000",
      "00000000000000000000000000000000",
      "00000000000000000011101110111000",
      "00000000000000000000101000100000"
    ],
    sad: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111111000011111100000000",
      "00000001111101100110111110000000",
      "00000001111111111111111110000000",
      "00000011111111111111111111000000",
      "00000011111111111111111111000000",
      "00000011111000000000011111000000",
      "00000001111101111110111110000000",
      "00000000111111111111111100000000",
      "00000000011111111111111000000000",
      "00000000001111000011110000000000",
      "00000000011100000000111000000000",
      "00000000111000000000011100000000",
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000000000000000000000000"
    ],
    dead: [
      "00000000000000000000000000000000",
      "00000000000000000000000000000000",
      "00000000000011111111000000000000",
      "00000000001111111111110000000000",
      "00000000011111111111111000000000",
      "00000000111101111110111100000000",
      "00000001111111111111111110000000",
      "00000001110011100111111110000000",
      "00000011110100010101111111000000",
      "00000011110111110101111111000000",
      "00000011110100010101111111000000",
      "00000001110101110101111110000000",
      "00000000110100010101111100000000",
      "00000000011111111111111000000000",
      "00000000001111000011110000000000",
      "00000000000110000001100000000000",
      "00000000000110000001100000000000",
      "00000000011111111111111000000000",
      "00000000111111111111111100000000",
      "00000000000000000000000000000000"
    ]
  }

  @impl true
  def mount(params, _session, socket) do
    mode = socket.assigns.live_action || :demo
    pet_keys = VirtualPet.Characters.all()
    current = default_pet_key(mode, params["pet"])
    pets = Map.new(pet_keys, &{&1, Pet.new_pet(&1)})
    pet = Map.fetch!(pets, current)

    {presence_key, socket} =
      if connected?(socket) do
        presence_key = presence_key(mode)

        Presence.track(self(), @presence_topic, presence_key, %{
          mode: mode,
          pet: current,
          status: pet.state.status
        })

        :timer.send_interval(2_000, :tick)
        {presence_key, socket}
      else
        {nil, socket}
      end

    {:ok,
     socket
     |> assign(:page_title, "Pocket Pets")
     |> assign(:mode, mode)
     |> assign(:presence_key, presence_key)
     |> assign(:pets, pets)
     |> assign(:current, current)
     |> assign(:pet, pet)
     |> assign(:pet_keys, pet_keys)
     |> assign(:colorway, "sticker")
     |> assign(:device_line, "HELLO")
     |> assign(:pet_line, Pet.line(pet))
     |> assign(:line_ref, 0)}
  end

  defp presence_key(mode), do: "#{mode}-#{System.unique_integer([:positive])}"

  @impl true
  def handle_info(:tick, socket) do
    current = socket.assigns.current
    old_pets = socket.assigns.pets
    old_pet = Map.fetch!(old_pets, current)
    old_mood = Pet.mood(old_pet)
    tick_keys = tick_keys(socket)

    pets =
      Map.new(old_pets, fn {key, pet} ->
        if key in tick_keys, do: {key, Pet.tick(pet)}, else: {key, pet}
      end)

    death_keys =
      for {key, before} <- old_pets,
          key in tick_keys,
          after_pet = Map.fetch!(pets, key),
          Pet.alive?(before) and Pet.dead?(after_pet),
          do: key

    Enum.each(death_keys, &Nursery.record_death/1)

    socket =
      socket
      |> assign(:pets, pets)
      |> sync_current_pet()

    socket =
      if current in death_keys do
        socket
        |> assign(:device_line, "RIP")
        |> update_presence()
        |> refresh_line(:death)
      else
        socket
      end

    socket =
      if current in death_keys or Pet.mood(socket.assigns.pet) == old_mood do
        socket
      else
        refresh_line(socket, :mood_change)
      end

    {:noreply, socket}
  end

  def handle_info({:pet_line, ref, line}, socket) do
    if ref == socket.assigns.line_ref do
      {:noreply, assign(socket, :pet_line, line)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("feed", _params, socket) do
    {:noreply, care(socket, &Pet.feed/1, "YUM", :feed)}
  end

  def handle_event("play", _params, socket) do
    {:noreply, care(socket, &Pet.play/1, "GAME", :play)}
  end

  def handle_event("nap", _params, socket) do
    {:noreply, care(socket, &Pet.nap/1, "SLEEP", :nap)}
  end

  def handle_event("choose", %{"pet" => pet_key}, socket) do
    pet_key = VirtualPet.Characters.normalize_key(pet_key)
    pet = Map.fetch!(socket.assigns.pets, pet_key)

    {:noreply,
     socket
     |> assign(:current, pet_key)
     |> sync_current_pet()
     |> assign(:device_line, if(Pet.dead?(pet), do: "RIP", else: "SWAP"))
     |> update_presence()
     |> refresh_line(:wake)}
  end

  def handle_event("revive", _params, socket) do
    {:noreply,
     socket
     |> update_current_pet(&Pet.revive/1)
     |> assign(:device_line, "READY")
     |> update_presence()
     |> refresh_line(:wake)}
  end

  defp default_pet_key(:play, nil), do: Enum.random(VirtualPet.Characters.all())
  defp default_pet_key(_mode, nil), do: :noodle
  defp default_pet_key(_mode, pet_key), do: VirtualPet.Characters.normalize_key(pet_key)

  defp tick_keys(%{assigns: %{mode: :demo, pet_keys: pet_keys}}), do: pet_keys
  defp tick_keys(%{assigns: %{current: current}}), do: [current]

  defp care(socket, action, device_line, event) do
    if Pet.dead?(socket.assigns.pet) do
      socket
    else
      socket
      |> update_current_pet(action)
      |> assign(:device_line, device_line)
      |> refresh_line(event)
    end
  end

  defp update_current_pet(socket, fun) do
    current = socket.assigns.current
    pets = Map.update!(socket.assigns.pets, current, fun)

    socket
    |> assign(:pets, pets)
    |> sync_current_pet()
  end

  defp sync_current_pet(socket) do
    assign(socket, :pet, Map.fetch!(socket.assigns.pets, socket.assigns.current))
  end

  defp update_presence(%{assigns: %{presence_key: nil}} = socket), do: socket

  defp update_presence(socket) do
    Presence.update(self(), @presence_topic, socket.assigns.presence_key, %{
      mode: socket.assigns.mode,
      pet: socket.assigns.current,
      status: socket.assigns.pet.state.status
    })

    socket
  end

  defp refresh_line(socket, event) do
    ref = socket.assigns.line_ref + 1
    socket = assign(socket, pet_line: Pet.line(socket.assigns.pet), line_ref: ref)

    if System.get_env("OLLAMA_PET_LINES") in ["1", "true", "yes"] do
      caller = self()
      pet = socket.assigns.pet

      Task.start(fn ->
        case VirtualPet.Characters.ai_line(pet, event) do
          {:ok, line} -> send(caller, {:pet_line, ref, line})
          :error -> :ok
        end
      end)
    end

    socket
  end

  defp sprite_rows(agent) do
    case Pet.mood(agent) do
      :dead -> @pet_sprites.dead
      :starving -> @pet_sprites.hungry
      :tired -> @pet_sprites.tired
      :sad -> @pet_sprites.sad
      :content -> content_frame(agent)
    end
  end

  defp content_frame(agent) do
    if rem(agent.state.age_ticks, 2) == 0 do
      @pet_sprites.content
    else
      @pet_sprites.content_alt
    end
  end

  defp lcd_cells(rows),
    do: rows |> Enum.concat(@blank) |> Enum.take(20) |> Enum.flat_map(&String.graphemes/1)

  defp stat_hearts(:hunger, value), do: hearts(100 - value)
  defp stat_hearts(_stat, value), do: hearts(value)

  defp stat_fill(:hunger, value), do: 100 - value
  defp stat_fill(_stat, value), do: value

  defp hearts(value) do
    filled = value |> div(20) |> max(0) |> min(5)

    for index <- 1..5 do
      if index <= filled, do: "full", else: "empty"
    end
  end

  defp stats(agent) do
    [
      %{key: :hunger, label: "Food", value: agent.state.hunger},
      %{key: :energy, label: "Sleep", value: agent.state.energy},
      %{key: :happiness, label: "Fun", value: agent.state.happiness}
    ]
  end

  defp mood_label(mood), do: mood |> Atom.to_string() |> String.upcase()

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class={["pet-stage", "pet-colorway-" <> @colorway]}>
        <h1 class="sr-only">Pocket pets on Dispersed</h1>

        <div class="pet-layout">
          <section class="toy-shell" aria-label="Pocket pet device">
            <div class="shell-shine" />
            <div class="shell-speckles" />

            <div class="lcd-screen">
              <div class="lcd-playfield">
                <div class="lcd-pixel-grid" aria-label={@pet.state.pet_name}>
                  <%= for cell <- lcd_cells(sprite_rows(@pet)) do %>
                    <span class={["lcd-pixel", cell == "1" && "is-on"]} />
                  <% end %>
                </div>
              </div>

              <div class="lcd-footer">
                <span>{@device_line}</span>
                <span>{mood_label(Pet.mood(@pet))}</span>
                <span>{@pet.state.age_ticks}</span>
              </div>
            </div>

            <div class="pet-voice">{@pet_line}</div>

            <div class="abc-buttons" aria-label="Device buttons">
              <button
                class="toy-button emoji-button"
                phx-click="feed"
                aria-label="Feed"
                disabled={Pet.dead?(@pet)}
              >
                <span aria-hidden="true">🍎</span>
              </button>
              <button
                class="toy-button emoji-button"
                phx-click="play"
                aria-label="Play"
                disabled={Pet.dead?(@pet)}
              >
                <span aria-hidden="true">🎾</span>
              </button>
              <button
                class="toy-button emoji-button"
                phx-click="nap"
                aria-label="Sleep"
                disabled={Pet.dead?(@pet)}
              >
                <span aria-hidden="true">😴</span>
              </button>
            </div>

            <button :if={Pet.dead?(@pet)} class="revive-button" phx-click="revive">
              Restart {@pet.state.pet_name}
            </button>
          </section>

          <aside class="care-panel" aria-label="Care dashboard">
            <div class="status-grid">
              <%= for stat <- stats(@pet) do %>
                <div class="status-row">
                  <div class="status-label">
                    <strong>{stat.label}</strong>
                    <span>{stat.value}</span>
                  </div>
                  <div class="pixel-meter" style={"--fill: #{stat_fill(stat.key, stat.value)}%"}>
                    <span />
                  </div>
                  <div class="heart-row">
                    <%= for heart <- stat_hearts(stat.key, stat.value) do %>
                      <span class={["heart-bit", heart]} />
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>

            <div :if={@mode == :demo} class="pet-picker" aria-label="Choose pet">
              <%= for key <- @pet_keys do %>
                <% character = VirtualPet.Characters.get(key) %>
                <button
                  class={["pet-token", @pet.state.pet_key == key && "is-active"]}
                  phx-click="choose"
                  phx-value-pet={Atom.to_string(key)}
                >
                  {character.name}
                </button>
              <% end %>
            </div>
          </aside>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
