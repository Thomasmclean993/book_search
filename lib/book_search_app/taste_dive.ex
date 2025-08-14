defmodule BookSearchApp.TasteDive do
  @base_url "https://TasteDive.com/api/similar"

  def get_recommendations(query) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: response}} <-
           http_client().get(@base_url, [],
             params: %{q: query, type: "book", k: "1054422-Booksear-F7CD0EC5", info: 1, limit: 10}
           ),
         {:ok, body} <- Jason.decode(response),
         {:ok, processed_recs} <- process_recs(body["similar"]["results"]) do
      {:ok, processed_recs}
    else
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API request failed with status #{code}, #{body}"}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :timeout}

      error ->
        error
    end
  end

  defp process_recs(recs) do
    parsed_recs =
      recs
      |> Enum.map(fn rec ->
        %{
          name: rec["name"],
          wiki_url: rec["wUrl"],
          summary: rec["description"]
        }
      end)
      # Filter out books with no summary
      |> Enum.reject(fn rec ->
        is_nil(rec.summary) or String.trim(rec.summary) == ""
      end)

    {:ok, parsed_recs}
  end

  defp http_client(), do: Application.get_env(:book_search_app, :http_client)
end
