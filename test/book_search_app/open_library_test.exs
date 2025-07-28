defmodule BookSearchApp.OpenLibraryTest do
  use ExUnit.Case, async: true
  import Mox

  alias BookSearchApp.OpenLibrary

  setup :verify_on_exit!

  describe "search_books/1" do
    test "returns processed books for successful API response" do
      json_response = """
      {
        "docs": [
          {
            "title": "Test Book",
            "author_name": ["Test Author"],
            "first_publish_year": 2020,
            "cover_i": 123456,
            "isbn": ["1234567890"]
          }
        ]
      }
      """

      expect(HTTPoison.BaseMock, :get, fn url, _headers, params ->
        assert url == "https://openlibrary.org/search.json"
        assert params == [params: %{q: "test"}]
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      assert {:ok, [book]} = OpenLibrary.search_books("test")

      assert book.title == "Test Book"
      assert book.authors == "Test Author"
      assert book.year == 2020
      assert book.isbn == ["1234567890"]
      assert book.cover_url == "https://covers.openlibrary.org/b/id/123456-M.jpg"
    end

    test "returns error for API failure" do
      expect(HTTPoison.BaseMock, :get, fn _, _, _ ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, :timeout} = OpenLibrary.search_books("test")
    end

    test "returns error for non-200 status code" do
      expect(HTTPoison.BaseMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 500, body: ""}}
      end)

      assert {:error, "API request failed with status 500"} = OpenLibrary.search_books("test")
    end

    test "handles malformed JSON response" do
      expect(HTTPoison.BaseMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "invalid json"}}
      end)

      assert {:error, %Jason.DecodeError{}} = OpenLibrary.search_books("test")
    end

    test "handles empty results gracefully" do
      expect(HTTPoison.BaseMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "{\"docs\": []}"}}
      end)

      assert {:ok, []} = OpenLibrary.search_books("test")
    end
  end

  describe "find_book/1" do
    test "Successfully retrieve a single book using the 'key' field from the index list" do
      single_book =
        %{
          "title" => "Test Book",
          "authors" => ["Test Author"],
          "year" => 2020,
          "cover_i" => 123_456,
          "isbn" => ["1234567890"],
          "cover_url" => "https.openlibrary.org/works/OL27448W.jpg"
        }

      {:ok, response} = OpenLibrary.display_single_book(single_book)

      assert response["title"] == "Test Book"
      assert response["authors"] == ["Test Author"]
      assert response["year"] == 2020
      assert response["isbn"] == ["1234567890"]
      assert response["cover_url"] == "https.openlibrary.org/works/OL27448W.jpg"
    end
  end
end
