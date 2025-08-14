defmodule BookSearchApp.HttpClientBehaviour do
  @callback get(String.t(), list(), keyword()) ::
              {:ok, %HTTPoison.Response{}} | {:error, %HTTPoison.Error{}}
end
