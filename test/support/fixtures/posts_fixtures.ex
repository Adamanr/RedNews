defmodule Rednews.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rednews.Posts` context.
  """

  @doc """
  Generate a articles.
  """
  def articles_fixture(attrs \\ %{}) do
    {:ok, articles} =
      attrs
      |> Enum.into(%{
        additional: %{},
        category: "some category",
        content: "some content",
        is_fake: true,
        likes: 42,
        tags: ["option1", "option2"],
        title: "some title"
      })
      |> Rednews.Posts.create_articles()

    articles
  end

  @doc """
  Generate a headlines.
  """
  def headlines_fixture(attrs \\ %{}) do
    {:ok, headlines} =
      attrs
      |> Enum.into(%{
        additional: %{},
        category: ["option1", "option2"],
        content: "some content",
        header: "some header",
        important: 42,
        is_fake: true,
        is_very_important: true,
        tags: ["option1", "option2"],
        title: "some title"
      })
      |> Rednews.Posts.create_headlines()

    headlines
  end
end
