defmodule BookSearchAppWeb.FallbackController do
  use BookSearchAppWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BookSearchAppWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(json: BookSearchAppWeb.ErrorJSON)
    |> render(:"403")
  end

  def call(conn, {:error, :timeout}) do
    conn
    |> put_status(502)
    |> put_view(json: BookSearchAppWeb.ErrorJSON)
    |> render(:"502")
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(502)
    |> put_view(json: BookSearchAppWeb.ErrorJSON)
    |> render(:"502")
  end
end
