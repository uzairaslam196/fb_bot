# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fb_bot_3,
  generators: [binary_id: true]

# Configures the endpoint
config :fb_bot_3, FbBot3Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FbBot3Web.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: FbBot3.PubSub,
  live_view: [signing_salt: "X0SGlFlL"]

config :fb_bot_3,
  page_access_token: System.get_env("PAGE_ACCESS_TOKEN"),
  verification_key: System.get_env("VERIFICATION_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
