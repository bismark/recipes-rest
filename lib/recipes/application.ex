defmodule Recipes.Application do
  use Application

  def start(_type, args) do
    import Supervisor.Spec

    children = [
      supervisor(Recipes.Web.Endpoint, []),
      worker(Recipes.DataStore, [args]),
    ]

    opts = [strategy: :one_for_one, name: Recipes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
