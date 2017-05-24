defmodule Recipes.Web.RatingController do

  use Recipes.Web, :controller
  import Recipes.Validation
  alias Recipes.DataStore


  action_fallback Recipes.Web.FallbackController


  def index(conn, %{"recipe_id" => id}) do
    with {:ok, recipe} <- DataStore.get(id)
    do
      json(conn, %{data: recipe.customer_ratings})
    end
  end


  def show(conn, %{"recipe_id" => id, "id" => customer_id}) do
    with {:ok, recipe} <- DataStore.get(id),
         {:ok, rating} <- fetch_rating(recipe.customer_ratings, customer_id)
    do
      json(conn, %{data: rating})
    end
  end


  def update(conn, %{"recipe_id" => id, "id" => customer_id} = params) do
    with {:ok, %{rating: rating}} <- required(:rating, params, %{},
                                              type: :integer),
         :ok <- validate_rating(rating),
         :ok <- DataStore.rate(id, customer_id, rating)
    do
      json(conn, %{data: rating})
    end
  end


  @spec fetch_rating(map, any) :: {:ok, integer} | {:error, :not_found}
  defp fetch_rating(ratings, id) do
    case Map.fetch(ratings, id) do
      :error -> {:error, :not_found}
      res -> res
    end
  end


  @spec validate_rating(integer) :: :ok | {:error, :bad_value}
  defp validate_rating(rating) when rating in 1..5, do: :ok
  defp validate_rating(_), do: {:error, {:bad_value, :rating}}


end

