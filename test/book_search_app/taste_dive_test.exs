defmodule BookSearchApp.TasteDiveTest do
  use ExUnit.Case, async: true
  import Mox
  alias BookSearchApp.TasteDive

  setup :verify_on_exit!

  @valid_body %{
    "similar" => %{
      "results" => [
        %{
          "name" => "Book One",
          "wUrl" => "https://example.com/book-one",
          "description" => "A thrilling novel about..."
        },
        %{
          "name" => "Book Two",
          "wUrl" => "https://example.com/book-two",
          "description" => "A sequel worth reading..."
        }
      ]
    }
  }

  describe "get_recommendations/1" do
    test "happy path: returns processed recommendations" do
      json = Jason.encode!(@valid_body)

      BookSearchApp.HttpClientMock
      |> expect(:get, fn url, headers, opts ->
        assert url == "https://TasteDive.com/api/similar"
        assert headers == []
        assert Keyword.has_key?(opts, :params)
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      assert {:ok, recs} = TasteDive.get_recommendations("Elixir")
      assert length(recs) == 2
      assert Enum.all?(recs, &Map.has_key?(&1, :name))
      assert Enum.all?(recs, &Map.has_key?(&1, :wiki_url))
      assert Enum.all?(recs, &Map.has_key?(&1, :summary))
    end

    test "removes recommendations with blank summaries" do
      body_with_blanks = %{
        "similar" => %{
          "results" => [
            %{
              "name" => "Book One",
              "wUrl" => "https://example.com/book-one",
              "description" => "Has summary"
            },
            %{
              "name" => "Book Two",
              "wUrl" => "https://example.com/book-two",
              "description" => ""
            },
            %{
              "name" => "Book Three",
              "wUrl" => "https://example.com/book-three",
              "description" => nil
            }
          ]
        }
      }

      json = Jason.encode!(body_with_blanks)

      BookSearchApp.HttpClientMock
      |> expect(:get, fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: json}}
      end)

      {:ok, recs} = TasteDive.get_recommendations("Elixir")
      names = Enum.map(recs, & &1.name)
      assert "Book One" in names
      refute "Book Two" in names
      refute "Book Three" in names
      assert length(recs) == 1
    end

    test "unhappy path: non-200 status returns error tuple" do
      BookSearchApp.HttpClientMock
      |> expect(:get, fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 500, body: "Server Error"}}
      end)

      assert {:error, msg} = TasteDive.get_recommendations("Elixir")
      assert msg =~ "API request failed with status 500"
    end

    test "unhappy path: timeout returns {:error, :timeout}" do
      BookSearchApp.HttpClientMock
      |> expect(:get, fn _url, _headers, _opts ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      assert {:error, :timeout} = TasteDive.get_recommendations("Elixir")
    end

    test "unhappy path: invalid JSON returns {:error, _}" do
      BookSearchApp.HttpClientMock
      |> expect(:get, fn _url, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: "not-a-json"}}
      end)

      assert {:error, _} = TasteDive.get_recommendations("Elixir")
    end
  end
end
