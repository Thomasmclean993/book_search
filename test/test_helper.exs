ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(BookSearchApp.Repo, :manual)
# Allow for future mocks
Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
# Override the config settings 
Mox.defmock(BookSearchApp.HttpClientMock, for: BookSearchApp.HttpClientBehaviour)

Application.put_env(:book_search_app, :http_client, BookSearchApp.HttpClientMock)
