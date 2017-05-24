defmodule Recipes.CSVLoaderTest do
  use ExUnit.Case

  alias Recipes.CSVLoader

  @test_data """
  id,created_at,updated_at,box_type,title,slug,short_title,marketing_description,calories_kcal,protein_grams,fat_grams,carbs_grams,bulletpoint1,bulletpoint2,bulletpoint3,recipe_diet_type_id,season,base,protein_source,preparation_time_minutes,shelf_life_days,equipment_needed,origin_country,recipe_cuisine,in_your_box,gousto_reference
  1,01/01/2017 00:00:01,01/01/2017 00:00:01,vegetarian,Food,food,,eat,100,12,35,0,hi,there,,meat,all,noodles,beef,35,4,things,place,asian,"hello, world",59
  """

  test "load" do
    Application.put_env(:recipes, :csv_file, {:test, @test_data})
    recipes = CSVLoader.load
    recipe = Map.fetch!(recipes, "1")
    assert "1" == recipe.id
    {:ok, date} = NaiveDateTime.new(2017, 1, 1, 0,0,1)
    assert date == recipe.created_at
    assert date == recipe.updated_at
    assert ["hi", "there"] == recipe.bulletpoints
    assert ["hello", "world"] == recipe.in_your_box
  end

end
