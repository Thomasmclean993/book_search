defmodule Support.FixtureHelper do
  def mock_response(file_name) do
    File.read("test/support/fixtures/#{file_name}.json")
  end
end
