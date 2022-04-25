import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :simple_ping_pong, SimplePingPongWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "V5eVe918kDyJT/1elx/2+IGFRzcr71pBPNTQdMCIWUPEcn3Or8trgJ+5awxLpkAs",
  server: false

# In test we don't send emails.
config :simple_ping_pong, SimplePingPong.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
