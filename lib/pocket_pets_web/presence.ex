defmodule PocketPetsWeb.Presence do
  use Phoenix.Presence,
    otp_app: :pocket_pets,
    pubsub_server: PocketPets.PubSub
end
