import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pocket_pets, PocketPetsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jgqM++FR3eF8H69GBV7LF9bOutxGCGD4nCAHR78Q31bB9U8msXdGSMrhKcY+t0ZI",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
