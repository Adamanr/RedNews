defmodule Rednews.PostsTest do
  use Rednews.DataCase

  alias Rednews.Posts

  describe "article" do
    alias Rednews.Posts.Articles

    import Rednews.PostsFixtures

    @invalid_attrs %{title: nil, content: nil, is_fake: nil, likes: nil, category: nil, tags: nil, additional: nil}

    test "list_article/0 returns all article" do
      articles = articles_fixture()
      assert Posts.list_article() == [articles]
    end

    test "get_articles!/1 returns the articles with given id" do
      articles = articles_fixture()
      assert Posts.get_articles!(articles.id) == articles
    end

    test "create_articles/1 with valid data creates a articles" do
      valid_attrs = %{title: "some title", content: "some content", is_fake: true, likes: 42, category: "some category", tags: ["option1", "option2"], additional: %{}}

      assert {:ok, %Articles{} = articles} = Posts.create_articles(valid_attrs)
      assert articles.title == "some title"
      assert articles.content == "some content"
      assert articles.is_fake == true
      assert articles.likes == 42
      assert articles.category == "some category"
      assert articles.tags == ["option1", "option2"]
      assert articles.additional == %{}
    end

    test "create_articles/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_articles(@invalid_attrs)
    end

    test "update_articles/2 with valid data updates the articles" do
      articles = articles_fixture()
      update_attrs = %{title: "some updated title", content: "some updated content", is_fake: false, likes: 43, category: "some updated category", tags: ["option1"], additional: %{}}

      assert {:ok, %Articles{} = articles} = Posts.update_articles(articles, update_attrs)
      assert articles.title == "some updated title"
      assert articles.content == "some updated content"
      assert articles.is_fake == false
      assert articles.likes == 43
      assert articles.category == "some updated category"
      assert articles.tags == ["option1"]
      assert articles.additional == %{}
    end

    test "update_articles/2 with invalid data returns error changeset" do
      articles = articles_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_articles(articles, @invalid_attrs)
      assert articles == Posts.get_articles!(articles.id)
    end

    test "delete_articles/1 deletes the articles" do
      articles = articles_fixture()
      assert {:ok, %Articles{}} = Posts.delete_articles(articles)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_articles!(articles.id) end
    end

    test "change_articles/1 returns a articles changeset" do
      articles = articles_fixture()
      assert %Ecto.Changeset{} = Posts.change_articles(articles)
    end
  end

  describe "headlines" do
    alias Rednews.Posts.Headlines

    import Rednews.PostsFixtures

    @invalid_attrs %{header: nil, title: nil, category: nil, content: nil, is_fake: nil, additional: nil, important: nil, is_very_important: nil, tags: nil}

    test "list_headlines/0 returns all headlines" do
      headlines = headlines_fixture()
      assert Posts.list_headlines() == [headlines]
    end

    test "get_headlines!/1 returns the headlines with given id" do
      headlines = headlines_fixture()
      assert Posts.get_headlines!(headlines.id) == headlines
    end

    test "create_headlines/1 with valid data creates a headlines" do
      valid_attrs = %{header: "some header", title: "some title", category: ["option1", "option2"], content: "some content", is_fake: true, additional: %{}, important: 42, is_very_important: true, tags: ["option1", "option2"]}

      assert {:ok, %Headlines{} = headlines} = Posts.create_headlines(valid_attrs)
      assert headlines.header == "some header"
      assert headlines.title == "some title"
      assert headlines.category == ["option1", "option2"]
      assert headlines.content == "some content"
      assert headlines.is_fake == true
      assert headlines.additional == %{}
      assert headlines.important == 42
      assert headlines.is_very_important == true
      assert headlines.tags == ["option1", "option2"]
    end

    test "create_headlines/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_headlines(@invalid_attrs)
    end

    test "update_headlines/2 with valid data updates the headlines" do
      headlines = headlines_fixture()
      update_attrs = %{header: "some updated header", title: "some updated title", category: ["option1"], content: "some updated content", is_fake: false, additional: %{}, important: 43, is_very_important: false, tags: ["option1"]}

      assert {:ok, %Headlines{} = headlines} = Posts.update_headlines(headlines, update_attrs)
      assert headlines.header == "some updated header"
      assert headlines.title == "some updated title"
      assert headlines.category == ["option1"]
      assert headlines.content == "some updated content"
      assert headlines.is_fake == false
      assert headlines.additional == %{}
      assert headlines.important == 43
      assert headlines.is_very_important == false
      assert headlines.tags == ["option1"]
    end

    test "update_headlines/2 with invalid data returns error changeset" do
      headlines = headlines_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_headlines(headlines, @invalid_attrs)
      assert headlines == Posts.get_headlines!(headlines.id)
    end

    test "delete_headlines/1 deletes the headlines" do
      headlines = headlines_fixture()
      assert {:ok, %Headlines{}} = Posts.delete_headlines(headlines)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_headlines!(headlines.id) end
    end

    test "change_headlines/1 returns a headlines changeset" do
      headlines = headlines_fixture()
      assert %Ecto.Changeset{} = Posts.change_headlines(headlines)
    end
  end
end
