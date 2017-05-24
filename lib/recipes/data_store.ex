defmodule Recipes.DataStore do

  alias __MODULE__, as: This
  alias Recipes.Data
  alias Recipes.CSVLoader

  def start_link(opts) do
    initial_data = seed(Keyword.get(opts, :seed_store, false))
    Agent.start_link(fn -> initial_data end, name: This)
  end


  @spec dump :: Data.t
  def dump do
    Agent.get(This, fn data -> data end)
  end


  @spec clear :: :ok
  def clear do
    Agent.update(This, fn _ -> %{} end)
  end


  @spec get(String.t) :: {:ok, Recipe.t} | {:error, :not_found}
  def get(id) do
    Data.get(dump(), id)
  end


  @spec list(map) :: {[Recipe.t], integer | nil}
  def list(opts) do
    Data.list(dump(), opts)
  end


  @spec rate(String.t, any, integer) :: :ok | {:error, :not_found}
  def rate(id, customer_id, rating) do
    Agent.get_and_update(This, fn data ->
      Data.rate(data, id, customer_id, rating)
    end)
  end


  @spec update(String.t, map) :: {:ok, Recipe.t} | {:error, :not_found}
  def update(id, args) do
    Agent.get_and_update(This, fn data ->
      Data.update(data, id, args)
    end)
  end


  @spec new(map) :: Recipe.t
  def new(args) do
    Agent.get_and_update(This, fn data ->
      Data.new(data, args)
    end)
  end


  @spec seed(boolean) :: map
  defp seed(false), do: %{}
  defp seed(true), do: CSVLoader.load


end
