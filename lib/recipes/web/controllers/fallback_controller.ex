defmodule Recipes.Web.FallbackController do
  use Recipes.Web, :controller

  def call(conn, {:error, {{:bad_type, expected}, field}}) do
    conn
      |> put_status(400)
      |> json(%{error: :bad_type, field: field, expected: expected})
  end

  def call(conn, {:error, {:bad_value, field}}) do
    conn
      |> put_status(400)
      |> json(%{error: :bad_value, field: field})
  end

  def call(conn, {:error, {:missing_arg, field}}) do
    conn
      |> put_status(400)
      |> json(%{error: :missing_arg, field: field})
  end

  def call(conn, {:error, :not_found}) do
    conn
      |> put_status(404)
      |> json(%{error: :not_found})
  end

  def call(conn, other) do
    require Logger
    Logger.error "Unexpected error: #{inspect other}"
    conn
      |> put_status(500)
      |> json(%{error: :unknown_error})
  end

end
