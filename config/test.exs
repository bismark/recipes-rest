use Mix.Config

config :recipes, Recipes.Web.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
