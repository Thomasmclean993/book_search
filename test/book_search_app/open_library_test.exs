defmodule BookSearchApp.OpenLibraryTest do
  use ExUnit.Case, async: true
  import Mox

  alias BookSearchApp.OpenLibrary

  setup :verify_on_exit!

  describe "search_books/1" do
    test "returns processed books for successful API response" do
      json = ~s({
        "docs": [{
          "title": "Test Book",
          "author_name": ["Test Author"],
          "first_publish_year": 2020,
          "cover_i": 123456,
          "isbn": ["1234567890"],
          "key": "/works/OL123W"
        }]
      })

      expect(BookSearchApp.HttpClientMock, :get, fn url, _headers, opts ->
        assert url == "https://openlibrary.org/search.json"
        assert opts == [params: %{q: "test"}]
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      assert {:ok, [book]} = OpenLibrary.search_books("test")
      assert book.title == "Test Book"
      assert book.authors == "Test Author"
      assert book.year == 2020
      assert book.isbn == ["1234567890"]
      assert book.key == "/works/OL123W"
      assert book.cover_url == "https://covers.openlibrary.org/b/id/123456-M.jpg"
    end

    test "returns error for API timeout" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, :timeout} = OpenLibrary.search_books("test")
    end

    test "returns error for non-200 status code" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 500, body: ""}}
      end)

      assert {:error, "API request failed with status 500"} = OpenLibrary.search_books("test")
    end

    test "handles malformed JSON response" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "not-json"}}
      end)

      assert {:error, %Jason.DecodeError{}} = OpenLibrary.search_books("test")
    end

    test "handles empty results" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "{\"docs\": []}"}}
      end)

      assert {:ok, []} = OpenLibrary.search_books("test")
    end
  end

  describe "get_description/1" do
    test "returns plain string description" do
      json = ~s({"description": "Plain description"})

      expect(BookSearchApp.HttpClientMock, :get, fn url, _, _ ->
        assert url == "https://openlibrary.org/works/OL1234W.json"
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      assert OpenLibrary.get_description("/works/OL1234W") == "Plain description"
    end

    test "returns description from map" do
      json = ~s({"description": {"value": "Mapped description"}})

      expect(BookSearchApp.HttpClientMock, :get, fn _url, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      assert OpenLibrary.get_description("/works/OL5678W") == "Mapped description"
    end

    test "returns nil if no description field" do
      json = ~s({"title": "No description"})

      expect(BookSearchApp.HttpClientMock, :get, fn _url, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      assert OpenLibrary.get_description("/works/OL9999W") == nil
    end

    test "returns nil on HTTP error" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert OpenLibrary.get_description("/works/OLFAIL") == nil
    end

    test "returns nil for non-200 status" do
      expect(BookSearchApp.HttpClientMock, :get, fn _, _, _ ->
        {:ok, %HTTPoison.Response{status_code: 404, body: "Not found"}}
      end)

      assert OpenLibrary.get_description("/works/OL404") == nil
    end
  end
end
