use Mix.Config

config :recipes,
  csv_file: "priv/static/recipe-data.csv"

config :recipes, Recipes.Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Recipes.Web.ErrorView, accepts: ~w(json)],
  secret_key_base: "X0RNDQoW8L9czXOTnBW0eR9BKGYj3vs7gDxyIJEprzVlXIg3WQs6GUrU/v83mXKE"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
