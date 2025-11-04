# BookSearchApp

## How to Setup

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

A simple web application that allows users to search for books based on a query and provides personalized book recommendations.

## Features

Fuzzy search functionality to find books related to the user's query
Integration with TasteDive and Open Library APIs to retrieve book data
Ability to select a book from search results and view its description
Personalized book recommendations based on the user's query and preferences

## Usage

Enter a query in the search form to start searching for books.
The app will display a list of books related to the query, along with a "Select" button next to each book.
Clicking the "Select" button will take the user to the book's details page, where they can view its description and other information.
The app will also provide personalized book recommendations based on the user's query and preferences.

## Technical Details

The app uses LiveView in combination with Phoenix and Ecto to handle the backend functionality. The search functionality is implemented using a fuzzy search library, and the app integrates with TasteDive and Open Library APIs for book data retrieval.
