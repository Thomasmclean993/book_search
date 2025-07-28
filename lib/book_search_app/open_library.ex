defmodule BookSearchApp.OpenLibrary do
  @base_url "https://openlibrary.org"
  @cover_url "https://covers.openlibrary.org/b/id"

  def fetch_books(query) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: response}} <-
           http_client().get("#{@base_url}/search.json", [], params: %{q: query}),
         {:ok, body} <- Jason.decode(response),
         processed_books <- process_books(body["docs"]),
         limited_return <- Enum.take(processed_books, 10) do
      {:ok, limited_return}
    else
      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "API request failed with status #{code}"}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :timeout}

      error ->
        error
    end
  end

  defp process_books(books) do
    Enum.map(books, fn book ->
      %{
        title: book["title"],
        authors: Enum.join(book["author_name"] || [], ", "),
        year: book["first_publish_year"],
        isbn: book["isbn"],
        key: book["key"],
        cover_url: get_cover_url(book)
      }
    end)
  end

  defp http_client(), do: Application.get_env(:book_search_app, :http_client)
  defp get_cover_url(%{"cover_i" => cover_id}), do: "#{@cover_url}/#{cover_id}-M.jpg"
  defp get_cover_url(_), do: nil
end
