defmodule Components.BookShow do
  use BookSearchAppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id="book-show" class="w-full md:w-2/3 lg:w-3/4">
      <%= if @book do %>
        <h3 class="font-bold text-xl mb-2">
          {@book["title"]}
        </h3>

        <%= if @book["authors"] do %>
          <p class="text-gray-700 mb-2">
            by {@book["authors"]}
          </p>
        <% end %>

        <%= if @book["year"] do %>
          <p class="text-gray-500 mb-2">
            First published: {@book["year"]}
          </p>
        <% end %>

        <%= if @book["isbn"] do %>
          <p class="text-gray-500 text-sm mt-2">
            ISBN: {@book["isbn"]}
          </p>
        <% end %>

        <%= if @book["key"] do %>
          <p class="text-gray-500 text-sm mt-2">
            Key: {@book["key"]}
          </p>
        <% end %>
      <% end %>
    </div>
    """
  end
end
