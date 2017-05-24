defmodule Recipes.ValidationTest do
  use ExUnit.Case

  alias Recipes.Validation

  test "required" do
    params = %{"foo" => "bar"}
    assert {:ok, %{foo: "bar"}} = Validation.required(:foo, params, %{})

    params = %{foo: "bar"}
    assert {:ok, %{foo: "bar"}} = Validation.required(:foo, params, %{})

    params = %{foo: 1}
    assert {:ok, %{foo: 1}} = Validation.required(:foo, params, %{}, type: :integer)

    params = %{foo: "1"}
    assert {:ok, %{foo: 1}} = Validation.required(:foo, params, %{}, type: :integer)

    params = %{foo: "abc"}
    assert {:error, {{:bad_type, :integer}, :foo}} == Validation.required(:foo, params, %{}, type: :integer)

    params = %{}
    assert {:error, {:missing_arg, :foo}} == Validation.required(:foo, params, %{}, type: :integer)

    params = %{foo: [1,2]}
    assert {:error, {{:bad_type, :string}, :foo}} == Validation.required(:foo, params, %{}, type: :list, contains: :string)

    params = %{foo: [1,2]}
    assert {:ok, %{foo: [1,2]}} == Validation.required(:foo, params, %{}, type: :list, contains: :integer)

    params = %{foo: ["1","2"]}
    assert {:ok, %{foo: [1,2]}} == Validation.required(:foo, params, %{}, type: :list, contains: :integer)

  end

  test "optional" do
    params = %{"foo" => "bar"}
    assert {:ok, %{}} = Validation.optional(:baz, params, %{})

    params = %{"foo" =>  "bar", "baz" => "buz"}
    assert {:ok, %{baz: "buz"}} = Validation.optional(:baz, params, %{})
  end


end
