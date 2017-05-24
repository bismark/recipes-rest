defmodule Recipes.Web.RecipeControllerTest do
  use Recipes.Web.ConnCase
  require Logger

  alias Recipes.DataStore
  alias Recipes.Recipe

  @create_args %{
    box_type: "gourmet",
    calories_kcal: 511,
    carbs_grams: 0,
    equipment_needed: "Appetite",
    fat_grams: 62,
    gousto_reference: 56,
    marketing_description: "Comprising all the best bits of the classic American number and none of the mayo, this is a warm & tasty chicken and bulgur salad with just a hint of Scandi influence. A beautifully summery medley of flavours and textures",
    origin_country: "Great Britain",
    preparation_time_minutes: 45,
    protein_grams: 11,
    protein_source: "pork",
    recipe_cuisine: "mexican",
    recipe_diet_type_id: "meat",
    season: "all",
    shelf_life_days: 4,
    slug: "pork-katsu-curry",
    title: "Pork Katsu Curry",
    bulletpoints: ["yum", "good"],
  }

  @update_args %{fat_grams: 55}


  setup %{conn: conn} do
    DataStore.clear()
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all recipes on index", %{conn: conn} do
    recipe = fixture(:recipe)
    conn = get conn, recipe_path(conn, :index)
    res = json_response(conn, 200)
    assert res["data"] == [convert_recipe(recipe)]
    assert res["next"] == nil
  end

  test "filtering", %{conn: conn} do
    recipe1 = fixture(:recipe)
    fixture(:recipe_2)

    conn = get conn, recipe_path(conn, :index, cuisine: "mexican")
    res = json_response(conn, 200)
    assert res["data"] == [convert_recipe(recipe1)]
    assert res["next"] == nil
  end


  test "pagination", %{conn: conn} do
    for _ <- 1..5, do: fixture(:recipe)

    conn = get conn, recipe_path(conn, :index, page_size: 2)
    res = json_response(conn, 200)
    assert [%{"id" => "1"}, %{"id" => "2"}] = res["data"]
    next = URI.parse(res["next"])
    params = URI.decode_query(next.query)
    assert "2" == params["page_size"]
    assert "2" == params["cursor"]

    conn = get conn, next.path <> "?" <> next.query
    res = json_response(conn, 200)
    assert [%{"id" => "3"}, %{"id" => "4"}] = res["data"]
    next = URI.parse(res["next"])
    params = URI.decode_query(next.query)
    assert "2" == params["page_size"]
    assert "4" == params["cursor"]

    conn = get conn, next.path <> "?" <> next.query
    res = json_response(conn, 200)
    assert [%{"id" => "5"}] = res["data"]
    assert nil == res["next"]
  end

  test "pagination & filtering", %{conn: conn} do
    fixture(:recipe)
    fixture(:recipe_2)
    fixture(:recipe)
    fixture(:recipe_2)
    fixture(:recipe)

    conn = get conn, recipe_path(conn, :index, page_size: 1, cuisine: "mexican")
    res = json_response(conn, 200)
    assert [%{"id" => "1"}] = res["data"]
    next = URI.parse(res["next"])
    params = URI.decode_query(next.query)
    assert "1" == params["page_size"]
    assert "1" == params["cursor"]

    conn = get conn, next.path <> "?" <> next.query
    res = json_response(conn, 200)
    assert [%{"id" => "3"}] = res["data"]
    next = URI.parse(res["next"])
    params = URI.decode_query(next.query)
    assert "1" == params["page_size"]
    assert "2" == params["cursor"]

    conn = get conn, next.path <> "?" <> next.query
    res = json_response(conn, 200)
    assert [%{"id" => "5"}] = res["data"]
    assert nil == res["next"]
  end


  test "creates recipe and refetch it", %{conn: conn} do
    conn = post conn, recipe_path(conn, :create), @create_args
    recipe = json_response(conn, 201)["data"]
    id = recipe["id"]

    fixture = fixture(:recipe)
      |> convert_recipe
      |> Map.drop(["created_at", "updated_at", "id"])
    recipe = Map.drop(recipe, ["created_at", "updated_at", "id"])

    assert fixture == recipe

    conn = get conn, recipe_path(conn, :show, id)
    assert %{"id" => ^id} = json_response(conn, 200)["data"]
  end

  test "create error", %{conn: conn} do
    conn = post conn, recipe_path(conn, :create), @update_args
    assert json_response(conn, 400)["error"] == "missing_arg"
  end

  test "updates recipe", %{conn: conn} do
    %Recipe{id: id} = recipe = fixture(:recipe)
    conn = put conn, recipe_path(conn, :update, recipe), @update_args
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, recipe_path(conn, :show, id)
    fat_grams = @update_args.fat_grams
    assert %{"id" => ^id, "fat_grams" => ^fat_grams} = json_response(conn, 200)["data"]
  end

  test "update error", %{conn: conn} do
    recipe = fixture(:recipe)
    conn = put conn, recipe_path(conn, :update, recipe), fat_grams: "abc"
    assert json_response(conn, 400)["error"] == "bad_type"
  end


  test "get non-existent", %{conn: conn} do
    conn = get conn, recipe_path(conn, :show, "abc")
    assert "not_found" = json_response(conn, 404)["error"]
  end

  test "index limited fields", %{conn: conn} do
    fixture(:recipe)
    fixture(:recipe)
    conn = get conn, recipe_path(conn, :index, fields: ["id", "recipe_cuisine"])
    assert [
      %{"id" => "1", "recipe_cuisine" => "mexican"},
      %{"id" => "2", "recipe_cuisine" => "mexican"},
    ] == json_response(conn, 200)["data"]
  end

  test "get limited fields", %{conn: conn} do
    recipe = fixture(:recipe)
    conn = get conn, recipe_path(conn, :show, recipe.id, fields: ["id", "recipe_cuisine"])
    assert %{"id" => "1", "recipe_cuisine" => "mexican"} == json_response(conn, 200)["data"]
  end

  test "create limited fields", %{conn: conn} do
    args = Map.put(@create_args, :fields, ["id", "recipe_cuisine", "junk"])
    conn = post conn, recipe_path(conn, :create), args
    assert %{"id" => "1", "recipe_cuisine" => "mexican"} == json_response(conn, 201)["data"]
  end

  test "updates limited fields", %{conn: conn} do
    recipe = fixture(:recipe)
    args = Map.put(@update_args, :fields, ["id", "recipe_cuisine"])
    conn = put conn, recipe_path(conn, :update, recipe.id), args
    assert %{"id" => "1", "recipe_cuisine" => "mexican"} = json_response(conn, 200)["data"]
  end

  # Helpers

  defp fixture(:recipe) do
    _fixture(@create_args)
  end

  defp fixture(:recipe_2) do
    @create_args
      |> Map.put(:recipe_cuisine, "indian")
      |> _fixture()
  end


  defp _fixture(args) do
    DataStore.new(args)
  end


  defp convert_recipe(recipe) do
    recipe
      |> convert_struct
      |> Map.update!("updated_at", &NaiveDateTime.to_iso8601/1)
      |> Map.update!("created_at", &NaiveDateTime.to_iso8601/1)
  end


  defp convert_struct(struct) do
    struct
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> Enum.into(%{})
  end


end
