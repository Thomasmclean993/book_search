defmodule BookSearchApp.Repo do
  use Ecto.Repo,
    otp_app: :book_search_app,
    adapter: Ecto.Adapters.Postgres,
    # Add this if you need transaction functions
    default_options: [timeout: 15_000]
end
