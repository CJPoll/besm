# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

get_env_bool =
  fn(env_var, default: default) do
    case System.get_env(env_var) do
      nil -> default
      "true" -> true
      "false" -> false
      other ->
        IO.puts("ENV var #{env_var} should be a boolean - got: #{default}")
    end
  end

get_env_log =
  fn() ->
    case System.get_env("BESM_LOG_LEVEL") do
      nil -> :warn
      "debug" -> :debug
      "info" -> :info
      "warn" -> :warn
      "error" -> :error
    end
  end

# General application configuration
config :besm,
  ecto_repos: [Besm.Repo]

# Configures the endpoint
config :besm, BesmWeb.Endpoint,
  url: [host: "BESM_HOST"],
  http: [port: 8080],
  secret_key_base: System.get_env("BESM_SECRET_KEY_BASE"),
  render_errors: [view: BesmWeb.ErrorView, accepts: ~w(html json)],
  debug_errors: get_env_bool.("BESM_DEV_ENVIRONMENT", default: false),
  code_reloader: get_env_bool.("BESM_DEV_ENVIRONMENT", default: false),
  check_origin: get_env_bool.("BESM_DEV_ENVIRONMENT", default: false),
  pubsub: [name: Besm.PubSub,
           adapter: Phoenix.PubSub.PG2],
  watchers:
    if get_env_bool.("BESM_DEV_ENVIRONMENT", default: false) do
      [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                      cd: Path.expand("../assets", __DIR__)]]
    else
      []
    end

if get_env_bool.("BESM_DEV_ENVIRONMENT", default: false) do
  config :besm, BesmWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
        ~r{priv/gettext/.*(po)$},
        ~r{lib/besm_web/views/.*(ex)$},
        ~r{lib/besm_web/templates/.*(eex)$}
      ]
    ]

  config :phoenix, :stacktrace_depth, 20
end

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: get_env_log.()
  metadata: [:request_id]

# Configure your database
config :besm, Besm.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  database: System.get_env("DATA_DB_NAME"),
  hostname: System.get_env("DATA_DB_HOST"),
  pool_size: System.get_env("DATA_DB_POOL_SIZE")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
