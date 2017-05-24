defmodule Recipes.Utils do

  def put_if_non_nil(kw, _k, nil), do: kw
  def put_if_non_nil(kw, k, v), do: Keyword.put(kw, k, v)

end
