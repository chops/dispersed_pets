defmodule PocketPetsWeb.SplashLive do
  use PocketPetsWeb, :live_view

  alias PocketPets.VirtualPet.Nursery
  alias PocketPetsWeb.Presence

  @presence_topic "pets:alive"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PocketPets.PubSub, @presence_topic)
      Nursery.subscribe()
    end

    play_url = play_url(socket)
    stats = Nursery.stats()

    {:ok,
     socket
     |> assign(:page_title, "Pocket Pets")
     |> assign(:play_url, play_url)
     |> assign(:qr_svg, qr_svg(play_url))
     |> assign(:alive_count, presence_count())
     |> assign(:dead_count, stats.dead)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{topic: @presence_topic, event: "presence_diff"},
        socket
      ) do
    {:noreply, assign(socket, :alive_count, presence_count())}
  end

  def handle_info({:pet_stats, stats}, socket) do
    {:noreply, assign(socket, :dead_count, stats.dead)}
  end

  defp play_url(socket) do
    socket
    |> current_url()
    |> URI.merge("/play")
    |> URI.to_string()
  end

  defp current_url(socket) do
    if connected?(socket) do
      case get_connect_params(socket) do
        %{"url" => url} when is_binary(url) -> URI.parse(url)
        _params -> fallback_uri()
      end
    else
      fallback_uri()
    end
  end

  defp fallback_uri, do: URI.parse(System.get_env("PUBLIC_URL") || "http://localhost:4000/")

  defp qr_svg(url) do
    url
    |> EQRCode.encode()
    |> EQRCode.svg(width: 460)
  end

  defp presence_count do
    @presence_topic
    |> Presence.list()
    |> Enum.count(fn {_key, %{metas: metas}} -> Enum.any?(metas, &alive_meta?/1) end)
  end

  defp alive_meta?(%{status: :dead}), do: false
  defp alive_meta?(%{status: "dead"}), do: false
  defp alive_meta?(_meta), do: true

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="splash-stage">
        <h1 class="sr-only">Pocket pets on Dispersed</h1>
        <section class="splash-hero" aria-label="Pocket Pets QR launch">
          <div class="splash-copy">
            <h1>Pocket Pets</h1>
            <p>Scan to hatch your own tiny agent.</p>
            <div class="splash-counts">
              <div class="splash-count">
                <strong>{@alive_count}</strong>
                <span>pets alive on this node</span>
              </div>
              <div class="splash-count is-dead">
                <strong>{@dead_count}</strong>
                <span>pets have died tonight</span>
              </div>
            </div>
            <.link navigate={~p"/demo"} class="demo-link">Open demo controls</.link>
          </div>

          <div class="qr-card" aria-label="Scan QR code">
            {Phoenix.HTML.raw(@qr_svg)}
            <span>{@play_url}</span>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
