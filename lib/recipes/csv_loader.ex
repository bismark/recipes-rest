defmodule Recipes.CSVLoader do

  alias Recipes.Recipe

  @spec load :: %{String.t => Recipe.t}
  def load do
    [headers | rows] = Application.get_env(:recipes, :csv_file)
      |> open_stream
      |> CSV.decode
      |> Enum.into([])

    headers = Enum.map(headers, &(String.to_existing_atom(&1)))
    Enum.map(rows, fn row ->
      recipe = headers
        |> Enum.zip(row)
        |> Enum.into(%{})
        |> from_raw
      {recipe.id, recipe}
    end)
      |> Enum.into(%{})
  end

  @spec from_raw(map) :: Recipe.t
  defp from_raw(data) do
    keys = [:bulletpoint1, :bulletpoint2, :bulletpoint3]
    {bulletpoints, data} = Map.split(data, keys)
    bulletpoints = bulletpoints
      |> Map.values
      |> Enum.reject(&(&1 == ""))

    data = data
      |> Map.put(:bulletpoints, bulletpoints)
      |> Map.update!(:created_at, &parse_date/1)
      |> Map.update!(:updated_at, &parse_date/1)
      |> Map.update!(:calories_kcal, &String.to_integer/1)
      |> Map.update!(:protein_grams, &String.to_integer/1)
      |> Map.update!(:fat_grams, &String.to_integer/1)
      |> Map.update!(:carbs_grams, &String.to_integer/1)
      |> Map.update!(:preparation_time_minutes, &String.to_integer/1)
      |> Map.update!(:shelf_life_days, &String.to_integer/1)
      |> Map.update!(:gousto_reference, &String.to_integer/1)
      |> Map.update!(:in_your_box, &(String.split(&1, ", ", trim: true)))
      |> Enum.reject(&(elem(&1, 1) == ""))
      |> Enum.into(%{})
    Recipe.new(data.id, data)
  end


  @spec parse_date(String.t) :: NaiveDateTime.t
  defp parse_date(date) do
    <<day :: binary-size(2), "/",
      month :: binary-size(2), "/",
      year :: binary-size(4), " ",
      hour :: binary-size(2), ":",
      minute :: binary-size(2), ":",
      second :: binary-size(2) >> = date

    {:ok, date} = NaiveDateTime.new(
      String.to_integer(year),
      String.to_integer(month),
      String.to_integer(day),
      String.to_integer(hour),
      String.to_integer(minute),
      String.to_integer(second)
    )
    date
  end


  def open_stream(path) when is_binary(path), do: File.stream!(path)

  def open_stream({:test, data}) do
    {:ok, stream} = StringIO.open(data)
    IO.binstream(stream, :line)
  end


end
