defmodule Recipes.Recipe do

  alias __MODULE__, as: This

  @derive [Poison.Encoder]

  @type t :: %This{
    id: String.t,
    created_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t,
    box_type: String.t,
    title: String.t,
    slug: String.t,
    short_title: String.t | nil,
    marketing_description: String.t,
    calories_kcal: integer,
    protein_grams: integer,
    fat_grams: integer,
    carbs_grams: integer,
    bulletpoints: [String.t],
    recipe_diet_type_id: String.t,
    season: String.t,
    base: String.t | nil,
    protein_source: String.t,
    preparation_time_minutes: integer,
    shelf_life_days: integer,
    equipment_needed: String.t,
    origin_country: String.t,
    recipe_cuisine: String.t,
    in_your_box: [String.t],
    gousto_reference: integer,
    customer_ratings: %{optional(any) => integer},
  }

  defstruct [
    :id,
    :created_at,
    :updated_at,
    :box_type,
    :title,
    :slug,
    :short_title,
    :marketing_description,
    :calories_kcal,
    :protein_grams,
    :fat_grams,
    :carbs_grams,
    :recipe_diet_type_id,
    :season,
    :base,
    :protein_source,
    :preparation_time_minutes,
    :shelf_life_days,
    :equipment_needed,
    :origin_country,
    :recipe_cuisine,
    :gousto_reference,
    in_your_box: [],
    bulletpoints: [],
    customer_ratings: %{},
  ]


  @spec new(String.t, map) :: This.t
  def new(id, args) do
    args = args
      |> Map.put(:id, id)
      |> Map.put_new(:created_at, now())
      |> Map.put_new(:updated_at, now())
    struct(This, args)
  end


  @spec update(This.t, map) :: This.t
  def update(this, args) do
    args = Map.put(args, :updated_at, now())
    struct(this, args)
  end


  @spec rate(This.t, any, integer) :: This.t
  def rate(this, customer_id, rating) do
    %This{this | customer_ratings: Map.put(this.customer_ratings, customer_id, rating)}
  end


  defp now do
    NaiveDateTime.utc_now()
      |> struct(microsecond: {0, 0})
  end


end
