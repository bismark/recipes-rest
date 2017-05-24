defmodule Recipes.Web.RecipeController do

  use Recipes.Web, :controller

  import Recipes.Validation

  alias Recipes.DataStore
  alias Recipes.Utils

  @keys [:key, :type, :create_required, :contains]
  @values [
    [:box_type, :string, true, nil],
    [:title, :string, true, nil],
    [:slug, :string, true, nil],
    [:short_title, :string, false, nil],
    [:marketing_description, :string, true, nil],
    [:calories_kcal, :integer, true, nil],
    [:protein_grams, :integer, true, nil],
    [:fat_grams, :integer, true, nil],
    [:carbs_grams, :integer, true, nil],
    [:bulletpoints, :list, false, :string],
    [:recipe_diet_type_id, :string, true, nil],
    [:season, :string, true, nil],
    [:base, :string, false, nil],
    [:protein_source, :string, true, nil],
    [:preparation_time_minutes, :integer, true, nil],
    [:shelf_life_days, :integer, true, nil],
    [:equipment_needed, :string, true, nil],
    [:origin_country, :string, true, nil],
    [:recipe_cuisine, :string, true, nil],
    [:in_your_box, :list, false, :string],
    [:gousto_reference, :integer, true, nil],
  ]
  @arg_specs Enum.map(@values, &(Enum.zip(@keys, &1) |> Enum.into(%{})))


  action_fallback Recipes.Web.FallbackController


  def index(conn, params) do
    with {:ok, args} <- optional(:cuisine, params, %{}, type: :string),
         {:ok, args} <- optional(:page_size, params, args, type: :integer),
         {:ok, args} <- optional(:cursor, params, args, type: :integer),
         {:ok, args} <- optional(:fields, params, args, type: :list, contains: :string)
    do
      {recipes, cursor} = DataStore.list(args)

      next = if cursor do
        opts = [cursor: cursor]
          |> Utils.put_if_non_nil(:cuisine, args[:cuisine])
          |> Utils.put_if_non_nil(:page_size, args[:page_size])
        recipe_url(conn, :index, opts)
      end

      recipes = Enum.map(recipes, &(view(&1, args[:fields])))
      json(conn, %{data: recipes, next: next})
    end
  end


  def show(conn, %{"id" => id} = params) do
    with {:ok, args} <- optional(:fields, params, %{}, type: :list, contains: :string),
         {:ok, recipe} <- DataStore.get(id)
    do
      json(conn, %{data: view(recipe, args[:fields])})
    end
  end


  def create(conn, params) do
    with {:ok, args} <- parse_params(params, true),
         {:ok, args} <- optional(:fields, params, args, type: :list, contains: :string)
    do
      recipe = DataStore.new(args)
      conn
        |> put_status(201)
        |> put_resp_header("location", recipe_path(conn, :show, recipe.id))
        |> json(%{data: view(recipe, args[:fields])})
    end
  end


  def update(conn, %{"id" => id} = params) do
    with {:ok, args} <- parse_params(params, false),
         {:ok, args} <- optional(:fields, params, args, type: :list, contains: :string),
         {:ok, recipe} <- DataStore.update(id, args)
    do
      json(conn, %{data: view(recipe, args[:fields])})
    end
  end


  @spec parse_params(map, boolean) :: {:ok, map} | {:error, term}
  defp parse_params(params, create?) do
    Enum.reduce_while(@arg_specs, {:ok, %{}}, fn spec, {_, acc} ->
      opts = if contains = spec.contains do
        [type: spec.type, contains: contains]
      else
        [type: spec.type]
      end

      res = if create? and spec.create_required do
        required(spec.key, params, acc, opts)
      else
        optional(spec.key, params, acc, opts)
      end

      case res do
        {:ok, acc} -> {:cont, {:ok, acc}}
        error -> {:halt, error}
      end
    end)
  end

  @spec view(Recipe.t, nil | [String.t]) :: map
  defp view(recipe, nil), do: recipe
  defp view(recipe, fields) do
    fields = Enum.reduce(fields, [], fn field, acc ->
      try do
        [String.to_existing_atom(field) | acc]
      rescue
        ArgumentError -> acc
      end
    end)

    Map.take(recipe, fields)
  end


end
