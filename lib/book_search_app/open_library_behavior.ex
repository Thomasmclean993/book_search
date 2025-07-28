defmodule OpenLibraryBehaviour do
  @callback search_books() :: {:ok, map()} | {:error, binary()}
end
