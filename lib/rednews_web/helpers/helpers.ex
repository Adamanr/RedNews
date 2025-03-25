defmodule RednewsWeb.Helpers do
  alias Rednews.Accounts
  use Gettext, backend: RednewsWeb.Gettext

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
  Translates a list of variables into their localized strings.

  ## Parameters
  - `options`: A list of variables to be translated.

  ## Returns
  - Returns a list of translated strings.
  """
  def translate_options(options) do
    Enum.map(options, fn en_term ->
      {Gettext.gettext(RednewsWeb.Gettext, en_term), en_term}
    end)
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
    if category == nil, do: "All", else: category
  end

  @doc """
  Converts a time period string into a more readable display format.

  ## Parameters
  - `time` - A string representing the time period. Expected values are:
    - "today" - will be converted to "for today"
    - "week" - will be converted to "for week"
    - "month" - will be converted to "for month"
    - "all" - will be converted to "all time"
    Any other value will be returned unchanged.

  ## Examples
      iex> convert_time_to_print("today")
      "for today"

      iex> convert_time_to_print("month")
      "for month"

      iex> convert_time_to_print("custom")
      "custom"

  ## Returns
  - Formatted string representation of the time period.
  """
  def convert_time_to_print(time) do
    case time do
      "today" -> "for today"
      "month" -> "for month"
      "week" -> "for week"
      "all" -> "all time"
      _ -> time
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
      "1 minute"
  """
  def calculate_reading_time(text) do
    word_count = String.split(text) |> length()
    minutes = div(word_count, @words_per_minute)

    format_time(minutes)
  end

  defp format_time(minutes) do
    if minutes > 0, do: "#{minutes}", else: "1"
  end
end
