defmodule Recipes.Schema do

  use Absinthe.Schema

  alias Recipes.DataStore

  query do
    field :recipe, non_null(:recipe) do
      arg :id, non_null(:id)
      resolve fn %{id: id}, _ ->
        DataStore.get(id)
      end
    end

    field :recipe_list, non_null(:recipe_list) do
      arg :cuisine, :string
      arg :page_size, :integer
      arg :cursor, :integer
      resolve fn args, _ ->
        {recipes, cursor} = DataStore.list(args)
        {:ok, %{cursor: cursor, recipes: recipes}}
      end
    end

  end

  mutation do
    field :create, type: non_null(:recipe) do
      arg :title, non_null(:string)
      arg :box_type, non_null(:string)
      arg :title, non_null(:string)
      arg :slug, non_null(:string)
      arg :short_title, :string
      arg :marketing_description, non_null(:string)
      arg :calories_kcal, non_null(:integer)
      arg :protein_grams, non_null(:integer)
      arg :fat_grams, non_null(:integer)
      arg :carbs_grams, non_null(:integer)
      arg :bulletpoints, non_null(list_of(non_null(:string)))
      arg :recipe_diet_type_id, non_null(:string)
      arg :season, non_null(:string)
      arg :base, :string
      arg :protein_source, non_null(:string)
      arg :preparation_time_minutes, non_null(:integer)
      arg :shelf_life_days, non_null(:integer)
      arg :equipment_needed, non_null(:string)
      arg :origin_country, non_null(:string)
      arg :recipe_cuisine, non_null(:string)
      arg :in_your_box, non_null(list_of(non_null(:string)))
      arg :gousto_reference, non_null(:integer)

      resolve fn args, _ ->
        {:ok, DataStore.new(args)}
      end
    end

    field :update, type: :recipe do
      arg :id, non_null(:id)
      arg :title, :string
      arg :box_type, :string
      arg :title, :string
      arg :slug, :string
      arg :short_title, :string
      arg :marketing_description, :string
      arg :calories_kcal, :integer
      arg :protein_grams, :integer
      arg :fat_grams, :integer
      arg :carbs_grams, :integer
      arg :bulletpoints, list_of(non_null(:string))
      arg :recipe_diet_type_id, :string
      arg :season, :string
      arg :base, :string
      arg :protein_source, :string
      arg :preparation_time_minutes, :integer
      arg :shelf_life_days, :integer
      arg :equipment_needed, :string
      arg :origin_country, :string
      arg :recipe_cuisine, :string
      arg :in_your_box, list_of(non_null(:string))
      arg :gousto_reference, :integer

      resolve fn args, _ ->
        case DataStore.update(args.id, args) do
          {:error, :not_found} -> {:error, message: "recipe not found", reason: :not_found}
          res -> res
        end
      end
    end

    field :rate, :recipe do
      arg :id, non_null(:id)
      arg :customer_id, non_null(:string)
      arg :rating, non_null(:integer)

      resolve fn args, _ ->
        with :ok <- validate_rating(args.rating),
             :ok <- DataStore.rate(args.id, args.customer_id, args.rating)
        do
          DataStore.get(args.id)
        else
          {:error, :invalid_rating} ->
            {:error, message: "invalid rating", reason: :invalid_rating}
          {:error, :not_found} ->
            {:error, message: "recipe not found", reason: :not_found}
        end
      end
    end

  end

  # Objects

  object :recipe_list do
    field :cursor, :integer
    field :recipes, non_null(list_of(non_null(:recipe)))
  end

  object :recipe do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :created_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)
    field :box_type, non_null(:string)
    field :title, non_null(:string)
    field :slug, non_null(:string)
    field :short_title, :string
    field :marketing_description, non_null(:string)
    field :calories_kcal, non_null(:integer)
    field :protein_grams, non_null(:integer)
    field :fat_grams, non_null(:integer)
    field :carbs_grams, non_null(:integer)
    field :bulletpoints, non_null(list_of(non_null(:string)))
    field :recipe_diet_type_id, non_null(:string)
    field :season, non_null(:string)
    field :base, :string
    field :protein_source, non_null(:string)
    field :preparation_time_minutes, non_null(:integer)
    field :shelf_life_days, non_null(:integer)
    field :equipment_needed, non_null(:string)
    field :origin_country, non_null(:string)
    field :recipe_cuisine, non_null(:string)
    field :in_your_box, non_null(list_of(non_null(:string)))
    field :gousto_reference, non_null(:integer)
    field :customer_ratings, non_null(list_of(non_null(:customer_ratings))) do
      resolve fn r, _, _ ->
        res = Enum.map(r.customer_ratings, fn {u, r} ->
          %{customer_id: u, rating: r}
        end)
        {:ok, res}
      end
    end

  end

  object :customer_ratings do
    field :customer_id, non_null(:string)
    field :rating, non_null(:integer)
  end

  # Types

  scalar :datetime, description: "ISO naive datetime" do
    parse &NaiveDateTime.from_iso8601(&1.value)
    serialize &NaiveDateTime.to_iso8601(&1)
  end

  # Helpers

  @spec validate_rating(integer) :: :ok | {:error, :invalid_rating}
  defp validate_rating(rating) when rating in 1..5, do: :ok
  defp validate_rating(_), do: {:error, :invalid_rating}

end
