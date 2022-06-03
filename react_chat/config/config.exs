# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :react_chat, ReactChatWeb.Endpoint,
  url: [host: "localhost"],
  check_origin: false,
  render_errors: [view: ReactChatWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ReactChat.PubSub,
  live_view: [signing_salt: "FPqpSi1+"]

config :react_chat, ReactChatWeb.RoomChannel, table_name: System.get_env("MESSAGES_NAME")

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :react_chat, ReactChat.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --loader:.js=jsx),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :ex_aws,
  access_key_id: [
    {:system, "AWS_ACCESS_KEY_ID"},
    :instance_role
  ],
  secret_access_key: [
    {:system, "AWS_SECRET_ACCESS_KEY"},
    :instance_role
  ],
  region: System.get_env("AWS_REGION")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
