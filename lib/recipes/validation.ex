defmodule Recipes.Validation do

  @moduledoc """
  Basic validation

  Available options:

  - type: validates the type
    - :string
    - :integer
    - :list
  - key: store in a different key
  - contains: validates the type of items in a list
  """

  @spec required(atom, map, map, Keyword.t) :: {:ok, map} | {:error, term}
  def required(key, args, acc, options \\ []) do
    case fetch(key, args) do
      :error -> {:error, {:missing_arg, key}}
      {:ok, value} -> validate_value(key, value, acc, options)
    end
  end


  @spec optional(atom, map, map, Keyword.t) :: {:ok, map} | {:error, term}
  def optional(key, args, acc, options \\ []) do
    case fetch(key, args) do
      :error -> {:ok, acc}
      {:ok, value} -> validate_value(key, value, acc, options)
    end
  end


  @spec validate_value(atom, any, map, Keyword.t) :: {:ok, map} | {:error, term}
  defp validate_value(key, value, acc, options) do
    with {:ok, value} <- validate_type(value, options),
         {:ok, value} <- validate_contains(value, options)
    do
      {:ok, Map.put(acc, key, value)}
    else
      {:error, error} -> {:error, {error, key}}
    end
  end


  @spec validate_type(any, Keyword.t) :: {:ok, any} | {:error, term}
  defp validate_type(value, options) do
    case Keyword.fetch(options, :type) do
      :error -> {:ok, value}
      {:ok, type} -> _validate_type(type, value)
    end
  end


  @spec _validate_type(atom, any) :: {:ok, any} | {:error, {:bad_type, atom}}
  defp _validate_type(:string, value) when is_binary(value), do: {:ok, value}

  defp _validate_type(:integer, value) when is_integer(value), do: {:ok, value}

  defp _validate_type(:integer, value) when is_binary(value) do
    try do
      {:ok, String.to_integer(value)}
    rescue
      ArgumentError -> {:error, {:bad_type, :integer}}
    end
  end

  defp _validate_type(:list, value) when is_list(value), do: {:ok, value}

  defp _validate_type(expected, _), do: {:error, {:bad_type, expected}}


  @spec validate_contains(any, Keyword.t) :: {:ok, any} | {:error, term}
  defp validate_contains(values, options) when is_list(values) do
    case Keyword.fetch(options, :contains) do
      :error -> {:ok, values}
      {:ok, type} ->
        with {:ok, values} <- _validate_contains(values, type),
             values = Enum.reverse(values),
        do: {:ok, values}
    end
  end

  defp validate_contains(value, _), do: {:ok, value}


  @spec _validate_contains([any], atom) :: {:ok, [any]} | {:error, term}
  defp _validate_contains(values, type) do
    Enum.reduce_while(values, {:ok, []}, fn value, {_,acc} ->
      case _validate_type(type, value) do
        {:ok, value} -> {:cont, {:ok, [value|acc]}}
        error -> {:halt, error}
      end
    end)
  end


  @spec fetch(atom, map) :: {:ok, any} | :error
  defp fetch(key, args) do
    with :error <- Map.fetch(args, key) do
      if is_atom(key) do
        Map.fetch(args, Atom.to_string(key))
      else
        :error
      end
    end
  end


end

