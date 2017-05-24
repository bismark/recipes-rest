defmodule Recipes.Data do

  alias __MODULE__, as: This
  alias Recipes.Recipe

  @opaque t :: %{optional(String.t) => Recipe.t}

  @spec get(This.t, String.t) :: {:ok, Recipe.t} | {:error, :not_found}
  def get(data, id) do
    case Map.fetch(data, id) do
      :error -> {:error, :not_found}
      res -> res
    end
  end


  @spec list(This.t, map) :: {[Recipe.t], integer | nil}
  def list(data, opts) do
    page_size = Map.get(opts, :page_size, 2)
    cursor = Map.get(opts, :cursor, 0)

    data = if cuisine = Map.get(opts, :cuisine) do
      Enum.filter(data, &(elem(&1,1).recipe_cuisine == cuisine))
    else
      Enum.into(data, [])
    end

    res = data
      |> Enum.map(fn {k,v} -> {String.to_integer(k), v} end)
      |> Enum.sort
      |> Enum.map(&(elem(&1, 1)))
      |> Enum.slice(cursor, page_size + 1)

    if length(res) > page_size do
      {Enum.drop(res, -1), page_size + cursor}
    else
      {res, nil}
    end
  end


  @spec rate(This.t, String.t, any, integer) :: {:ok | {:error, :not_found}, This.t}
  def rate(data, id, customer_id, rating) do
    if Map.has_key?(data,id) do
      {:ok, Map.update!(data, id, &(Recipe.rate(&1, customer_id, rating)))}
    else
      {{:error, :not_found}, data}
    end
  end


  @spec update(This.t, String.t, map) :: {{:ok, Recipe.t} | {:error, :not_found}, This.t}
  def update(data, id, args) do
    if Map.has_key?(data, id) do
      data = Map.update!(data, id, &(Recipe.update(&1, args)))
      {{:ok, Map.fetch!(data, id)}, data}
    else
      {{:error, :not_found}, data}
    end
  end


  @spec new(This.t, map) :: {Recipe.t, This.t}
  def new(data, args) do
    id = data
      |> Map.keys
      |> Enum.map(&String.to_integer/1)
      |> Enum.max(fn -> 0 end)
      |> Kernel.+(1)
      |> Integer.to_string
    recipe = Recipe.new(id, args)
    {recipe, Map.put(data, id, recipe)}
  end

end
