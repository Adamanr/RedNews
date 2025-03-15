defmodule RednewsWeb.Helpers do
  alias Rednews.Accounts

  @moduledoc """
  A utility module providing helper functions for common tasks such as user session management,
  data formatting, and text processing.

  This module includes functions for:
  - Retrieving the current user from a session.
  - Formatting categories and date ranges for display.
  - Calculating the estimated reading time for a given text.

  These helpers are designed to simplify repetitive tasks and improve code readability across the application.
  """

  @doc """
  Converts Markdown to HTML.
  """
  def to_html(markdown) do
    Earmark.as_html!(markdown, %Earmark.Options{
      gfm: true,
      breaks: true
    })
  end

  @doc """
  Retrieves the current user based on the session token.

  ## Parameters
  - `session`: A map containing session data, including the user token (`user_token`).

  ## Returns
  - Returns a `%User{}` struct if the session token exists and the user is found.
  - Returns `nil` if the session token is missing or the user is not found.

  ## Examples
    iex> get_current_user(%{"user_token" => "valid_token"})
    %User{}

    iex> get_current_user(%{})
    nil
  """
  def get_current_user(session) do
    if not is_nil(session["user_token"]) do
      Accounts.get_user_by_session_token(session["user_token"])
    else
      nil
    end
  end

  @doc """
  Converts a category into a display-friendly format.

  ## Parameters
  - `category`: A string representing the category. Can be `nil`.

  ## Returns
  - Returns the string `"All"` if the category is `nil`.
  - Returns the original category if it is not `nil`.

  ## Examples
      iex> convert_category_to_print(nil)
      "All"

      iex> convert_category_to_print("Technology")
      "Technology"
  """
  def convert_category_to_print(category) do
    if category == nil, do: "Все", else: category
  end

  @doc """
  Converts a date range identifier into a human-readable format.

  ## Parameters
  - `date`: A string representing the date range. Possible values: `"month"`, `"today"`, `"week"`, `"all"`.

  ## Returns
  - Returns a string describing the date range in a human-readable format.

  ## Examples
      iex> convert_date_to_print("month")
      "for the month"

      iex> convert_date_to_print("today")
      "for today"
  """
  def convert_date_to_print(date) do
    case date do
      "month" -> "за месяц"
      "today" -> "за сегодня"
      "week" -> "за неделю"
      "all" -> "за все время"
    end
  end

  @words_per_minute 200

  @doc """
  Calculates the estimated reading time for a given text.

  ## Parameters
  - `text`: A string containing the text to analyze.

  ## Returns
  - Returns a formatted string representing the estimated reading time in minutes and seconds.

  ## Examples
      iex> calculate_reading_time("This is a sample text.")
      "1 minute 30 seconds"
  """
  def calculate_reading_time(text) do
    word_count = String.split(text) |> length()
    minutes = div(word_count, @words_per_minute)
    seconds = rem(word_count, @words_per_minute) * 60 / @words_per_minute

    format_time(minutes, round(seconds))
  end

  defp format_time(minutes, seconds) when minutes > 0 do
    "#{minutes} мин #{seconds} сек"
  end

  defp format_time(_, seconds) do
    "#{seconds} сек"
  end
end
