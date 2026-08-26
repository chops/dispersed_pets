defmodule PocketPets.VirtualPet.Characters do
  @moduledoc """
  Character definitions and canned expression lookup for virtual pets.
  """

  @character_specs %{
    noodle: %{
      name: "Noodle",
      defaults: %{hunger: 42, happiness: 74, energy: 68},
      identity: %{
        role: "Dramatic digital companion",
        background: "Born hungry on a Dispersed node"
      },
      personality: %{
        traits: ["dramatic", "snack-motivated", "secretly brave"],
        quirks: ["Negotiates every snack like a treaty"]
      },
      voice: %{
        tone: :playful,
        style: "Short, theatrical, snack-focused",
        expressions: [
          "Noodle is thriving with suspicious elegance.",
          "Noodle requires one heroic snack.",
          "Noodle is conserving greatness under this blanket.",
          "Noodle requests applause and emotional support."
        ]
      }
    },
    byte: %{
      name: "Byte",
      defaults: %{hunger: 30, happiness: 58, energy: 82},
      identity: %{
        role: "Tiny routine-loving robot",
        background: "Compiled itself during a quiet boot"
      },
      personality: %{
        traits: ["precise", "sleepy", "proud"],
        quirks: ["Rates snacks for structural integrity"]
      },
      voice: %{
        tone: :friendly,
        style: "Concise, orderly, warm",
        expressions: [
          "Byte reports all tiny systems nominal.",
          "Byte has detected a snack-shaped optimization.",
          "Byte will now enter premium rest mode.",
          "Byte requests a structured play interval."
        ]
      }
    },
    miso: %{
      name: "Miso",
      defaults: %{hunger: 52, happiness: 86, energy: 61},
      identity: %{
        role: "Playful attention engine",
        background: "Appeared wherever the action was loudest"
      },
      personality: %{
        traits: ["playful", "competitive", "attention-seeking"],
        quirks: ["Treats every button press as a challenge"]
      },
      voice: %{
        tone: :playful,
        style: "Fast, eager, mischievous",
        expressions: [
          "Miso is absolutely ready for the next excellent idea.",
          "Miso claims this snack as a victory.",
          "Miso is recharging for a rematch.",
          "Miso needs a game, a cheer, and possibly confetti."
        ]
      }
    }
  }

  @mood_index %{content: 0, starving: 1, tired: 2, sad: 3, dead: 3}

  def all do
    Map.keys(@character_specs)
  end

  def normalize_key(key) when is_atom(key) do
    if Map.has_key?(@character_specs, key), do: key, else: :noodle
  end

  def normalize_key(key) when is_binary(key) do
    Enum.find(all(), :noodle, &(Atom.to_string(&1) == key))
  end

  def get(key) when is_binary(key), do: key |> normalize_key() |> get()

  def get(key) do
    key = normalize_key(key)
    spec = Map.fetch!(@character_specs, key)
    character = Jido.Character.new!(Map.take(spec, [:name, :identity, :personality, :voice]))

    %{
      key: key,
      name: character.name,
      character: character,
      defaults: spec.defaults
    }
  end

  def line(key, mood, event) do
    character =
      key
      |> normalize_key()
      |> get()
      |> Map.fetch!(:character)

    expressions = character.voice.expressions

    dead_line(character.name, mood) ||
      event_line(event) ||
      expressions
      |> Enum.at(Map.fetch!(@mood_index, mood))
      |> Kernel.||(List.first(expressions))
  end

  def ai_line(agent, event) do
    character =
      agent.state.pet_key
      |> normalize_key()
      |> get()
      |> Map.fetch!(:character)

    with {:ok, %{status: 200, body: %{"message" => %{"content" => text}}}} <-
           Req.post(ollama_url(),
             json: ollama_body(character, agent, event),
             receive_timeout: 1_200
           ),
         line when line != "" <- clean_line(text) do
      {:ok, line}
    else
      _error -> :error
    end
  end

  defp ollama_url do
    System.get_env("OLLAMA_URL", "http://127.0.0.1:11434/api/chat")
  end

  defp ollama_body(character, agent, event) do
    %{
      model: System.get_env("OLLAMA_MODEL", "qwen2.5:0.5b"),
      stream: false,
      options: %{num_predict: 24, temperature: 0.9},
      messages: [
        %{role: "system", content: Jido.Character.to_system_prompt(character)},
        %{role: "user", content: ai_prompt(agent, event)}
      ]
    }
  end

  defp ai_prompt(agent, event) do
    """
    The virtual pet event is #{event}.
    Current stats: hunger #{agent.state.hunger}, happiness #{agent.state.happiness}, energy #{agent.state.energy}.
    Reply as the pet in one playful sentence, 12 words or fewer. No quotes.
    """
  end

  defp clean_line(text) do
    text
    |> String.trim()
    |> String.trim("\"'")
    |> String.replace(~r/\s+/, " ")
    |> String.slice(0, 96)
  end

  defp dead_line(name, :dead), do: "#{name} is a tiny ghost. Press restart."
  defp dead_line(_name, _mood), do: nil

  defp event_line(:feed), do: "Snack accepted. Emotional balance has improved."
  defp event_line(:play), do: "That counted as enrichment. Possibly legendary enrichment."
  defp event_line(:nap), do: "Blanket protocol engaged. Please lower the lights."
  defp event_line(_event), do: nil
end
