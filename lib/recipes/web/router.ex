defmodule Recipes.Web.Router do
  use Recipes.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/rest", Recipes.Web do
    pipe_through :api

    resources "/recipes", RecipeController, except: [:new, :edit, :delete] do
      resources "/ratings", RatingController, except: [:new, :edit, :create, :delete]
    end
  end

  # GraphQL

  forward "/graphql", Absinthe.Plug,
    schema: Recipes.Schema

end
