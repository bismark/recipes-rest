defmodule Recipes.Web.RatingControllerTest do
  use Recipes.Web.ConnCase
  require Logger

  alias Recipes.DataStore

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


  setup %{conn: conn} do
    DataStore.clear()
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "index non-existent", %{conn: conn} do
    conn = get conn, recipe_rating_path(conn, :index, "abc")
    res = json_response(conn, 404)
    assert res["error"] == "not_found"
  end

  test "index empty", %{conn: conn} do
    recipe = fixture(:recipe)

    conn = get conn, recipe_rating_path(conn, :index, recipe.id)
    res = json_response(conn, 200)
    assert res["data"] == %{}
  end

  test "index", %{conn: conn} do
    recipe = fixture(:recipe)
    DataStore.rate(recipe.id, "bob", 1)

    conn = get conn, recipe_rating_path(conn, :index, recipe.id)
    res = json_response(conn, 200)
    assert res["data"] == %{"bob" => 1}
  end


  test "show non-existent recipe", %{conn: conn} do
    conn = get conn, recipe_rating_path(conn, :show, "abc", "bob")
    res = json_response(conn, 404)
    assert res["error"] == "not_found"
  end

  test "show non-existent user", %{conn: conn} do
    recipe = fixture(:recipe)
    conn = get conn, recipe_rating_path(conn, :show, recipe.id, "bob")
    res = json_response(conn, 404)
    assert res["error"] == "not_found"
  end

  test "show", %{conn: conn} do
    recipe = fixture(:recipe)
    DataStore.rate(recipe.id, "bob", 1)

    conn = get conn, recipe_rating_path(conn, :show, recipe.id, "bob")
    res = json_response(conn, 200)
    assert res["data"] == 1
  end


  test "update bad args", %{conn: conn} do
    recipe = fixture(:recipe)

    conn = put conn, recipe_rating_path(conn, :update, recipe.id, "bob", %{rating: "abc"})
    res = json_response(conn, 400)
    assert res["error"] == "bad_type"

    conn = put conn, recipe_rating_path(conn, :update, recipe.id, "bob", %{rating: 0})
    res = json_response(conn, 400)
    assert res["error"] == "bad_value"

    conn = put conn, recipe_rating_path(conn, :update, recipe.id, "bob", %{rating: 6})
    res = json_response(conn, 400)
    assert res["error"] == "bad_value"
  end

  test "update", %{conn: conn} do
    recipe = fixture(:recipe)

    conn = put conn, recipe_rating_path(conn, :update, recipe.id, "bob", %{rating: 1})
    res = json_response(conn, 200)
    assert res["data"] == 1
  end


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


end
