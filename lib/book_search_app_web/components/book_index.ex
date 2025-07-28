defmodule Components.BookIndex do
  use BookSearchAppWeb, :live_component

  def list_books(assigns) do
    ~H"""
    <div class="mt-6 grid grid-cols-1 gap-6">
      <%= for book <- @books do %>
        <div class="border rounded-lg p-4 hover:shadow-lg transition-shadow flex flex-col md:flex-row gap-6">
          <!-- Book Cover (Left) -->
          <div class="w-full md:w-1/3 lg:w-1/4 flex justify-center">
            <%= if book.cover_url do %>
              <img
                src={book.cover_url}
                alt={"Cover of #{book.title}"}
                class="h-48 md:h-64 object-contain shadow-md"
                onerror="this.src='/images/no-cover.png'"
              />
            <% else %>
              <div class="h-48 md:h-64 w-full bg-gray-100 flex items-center justify-center text-gray-400">
                <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1"
                    d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                  >
                  </path>
                </svg>
              </div>
            <% end %>
          </div>
          
    <!-- Book Details (Right) -->
          <div class="w-full md:w-2/3 lg:w-3/4">
            <h3 class="font-bold text-xl mb-2">
              <a phx-click={
                JS.push("single_search",
                  value: %{query: book}
                )
              }>
                {book.title}
              </a>
            </h3>

            <%= if book.authors do %>
              <p class="text-gray-700 mb-2">
                by {book.authors}
              </p>
            <% end %>

            <%= if book.year do %>
              <p class="text-gray-500 mb-2">
                First published: {book.year}
              </p>
            <% end %>

            <%= if book.isbn do %>
              <p class="text-gray-500 text-sm mt-2">
                ISBN: {book.isbn}
              </p>
            <% end %>

            <%= if book.key do %>
              <p class="text-gray-500 text-sm mt-2">
                KEY: {book.key}
              </p>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
