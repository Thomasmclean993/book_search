defmodule BookSearchAppWeb.BookSearchLive do
  use BookSearchAppWeb, :live_view

  alias BookSearchApp.{OpenLibrary, TasteDive}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       books: [],
       selected_book: nil,
       query: "",
       loading: false,
       error: nil,
       recommendations: []
     )}
  end

  # Handles search form submit
  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:search_books, query})

    {:noreply,
     assign(socket,
       loading: true,
       error: nil,
       query: query,
       books: [],
       selected_book: nil,
       recommendations: []
     )}
  end

  # Handles selection of a book from the search results
  def handle_event("select_book", %{"key" => book_key}, socket) do
    # Find the selected book from search results
    base_book = Enum.find(socket.assigns.books, fn book -> book[:key] == book_key end)

    # If we found it, fetch description from OpenLibrary detail API
    book_with_description =
      if base_book do
        # Only call works/{id}.json here
        description = OpenLibrary.get_description(book_key)
        Map.put(base_book, :description, description)
      else
        nil
      end

    # Fetch TasteDive recommendations (if title available)
    recommendations =
      if book_with_description do
        case TasteDive.get_recommendations(book_with_description[:title]) do
          {:ok, recs} -> recs
          _ -> []
        end
      else
        []
      end

    {:noreply,
     assign(socket,
       selected_book: book_with_description,
       recommendations: recommendations
     )}
  end

  # Search results fetch
  def handle_info({:search_books, query}, socket) do
    case OpenLibrary.search_books(query) do
      {:ok, books} ->
        {:noreply, assign(socket, books: books, loading: false, error: nil)}

      {:error, reason} ->
        {:noreply, assign(socket, loading: false, error: reason)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-2xl font-bold mb-6">Book Search</h1>

      <form phx-submit="search">
        <div class="flex gap-2">
          <input
            type="text"
            name="query"
            value={@query}
            placeholder="Search for books..."
            class="flex-grow px-4 py-2 border rounded-lg"
          />
          <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            Search
          </button>
        </div>
      </form>

      <%= if @loading do %>
        <div class="mt-4 text-gray-600">Searching...</div>
      <% end %>

      <%= if @error do %>
        <div class="mt-4 text-red-600">Error: {inspect(@error)}</div>
      <% end %>

      <%= if @selected_book do %>
        <.live_component
          module={BookSearchAppWeb.BookDetailsComponent}
          id="book-details"
          book={@selected_book}
          recommendations={@recommendations}
        />
      <% else %>
        <.live_component module={BookSearchAppWeb.BookListComponent} id="book-list" books={@books} />
      <% end %>
    </div>
    """
  end
end
