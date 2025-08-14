defmodule BookSearchAppWeb.BookDetailsComponent do
  use BookSearchAppWeb, :live_component

  def render(assigns) do
    assigns = Map.put_new(assigns, :book, nil)

    ~H"""
    <div id="book-details" class="mt-6 border-t pt-6 w-full">
      <%= if @book do %>
        <!-- Book header: cover + metadata -->
        <div class="flex flex-col md:flex-row gap-6 items-start w-full">
          <%= if @book[:cover_url] do %>
            <img
              src={@book[:cover_url]}
              alt="Book Cover"
              class="w-full max-w-xs md:w-60 h-auto rounded shadow"
            />
          <% end %>

          <div class="flex-1">
            <h2 class="text-2xl font-bold mb-2">{@book[:title]}</h2>

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
                ISBN: {Enum.join(@book[:isbn], ", ")}
              </p>
            <% end %>

            <%= if @book[:key] do %>
              <p class="text-gray-600 text-sm">
                Key: {@book[:key]}
              </p>
            <% end %>
          </div>
        </div>
        
    <!-- Book Description -->
        <%= if @book[:description] do %>
          <div class="mt-4 prose prose-sm text-gray-700 max-w-none">
            {@book[:description]}
          </div>
        <% end %>
        
    <!-- Recommendations -->
        <div class="mt-8 w-full">
          <h3 class="text-lg font-semibold mb-4">Recommendations</h3>

          <%= if Enum.empty?(@recommendations) do %>
            <p class="text-gray-500">No recommendations found.</p>
          <% else %>
            <div class="flex flex-col gap-4">
              <%= for rec <- @recommendations do %>
                <div class="bg-white rounded-lg shadow p-4 w-full">
                  <h4 class="font-bold text-md mb-1">{rec.name}</h4>

                  <%= if rec.wiki_url do %>
                    <a
                      href={rec.wiki_url}
                      target="_blank"
                      class="text-blue-600 hover:underline text-sm block mb-2"
                    >
                      Wiki
                    </a>
                  <% end %>

                  <p class="text-gray-600 text-sm mt-2">
                    {rec.summary}
                  </p>
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
