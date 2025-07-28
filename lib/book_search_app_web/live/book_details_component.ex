defmodule BookSearchAppWeb.BookDetailsComponent do
  use BookSearchAppWeb, :live_component

  def render(assigns) do
    assigns = Map.put_new(assigns, :book, nil)

    ~H"""
    <div id="book-details" class="mt-6 border-t pt-6">
      <%= if @book do %>
        <div class="flex gap-6 items-start">
          <%= if @book[:cover_url] do %>
            <img src={@book[:cover_url]} alt="Book Cover" class="w-40 h-auto rounded shadow" />
          <% end %>
          <div>
            <h2 class="text-xl font-bold mb-2">{@book[:title]}</h2>
            <%= if @book[:authors] do %>
              <p class="text-gray-700 mb-1">
                by {@book[:authors]}
              </p>
            <% end %>
            <%= if @book[:year] do %>
              <p class="text-gray-600 mb-1">
                First published: {@book[:year]}
              </p>
            <% end %>
            <%= if @book[:isbn] do %>
              <p class="text-gray-600 mb-1">
                ISBN: {@book[:isbn]}
              </p>
            <% end %>
            <%= if @book[:key] do %>
              <p class="text-gray-600 text-sm">
                Key: {@book[:key]}
              </p>
            <% end %>
          </div>
        </div>
        <!-- Recs cards -->
        <div class="mt-6">
          <h3 class="text-lg font-semibold mb-2">Recommendations</h3>
          <%= if Enum.empty?(@recommendations) do %>
            <p class="text-gray-500">No recommendations found.</p>
          <% else %>
            <div class="flex flex-wrap gap-4">
              <%= for rec <- @recommendations do %>
                <div class="bg-white rounded-lg shadow p-4 w-72">
                  <h4 class="font-bold text-md mb-1">{rec.name}</h4>
                  <%= if rec.wiki_url do %>
                    <a
                      href={rec.wiki_url}
                      target="_blank"
                      class="text-blue-600 hover:underline text-sm"
                    >
                      Wiki
                    </a>
                    <p class="text-gray-600 text-sm mt-2">{rec.summary}</p>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
