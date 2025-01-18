defmodule RednewsWeb.ArticlesLiveTest do
  use RednewsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rednews.PostsFixtures

  @create_attrs %{title: "some title", content: "some content", is_fake: true, likes: 42, category: "some category", tags: ["option1", "option2"], additional: %{}}
  @update_attrs %{title: "some updated title", content: "some updated content", is_fake: false, likes: 43, category: "some updated category", tags: ["option1"], additional: %{}}
  @invalid_attrs %{title: nil, content: nil, is_fake: false, likes: nil, category: nil, tags: [], additional: nil}

  defp create_articles(_) do
    articles = articles_fixture()
    %{articles: articles}
  end

  describe "Index" do
    setup [:create_articles]

    test "lists all article", %{conn: conn, articles: articles} do
      {:ok, _index_live, html} = live(conn, ~p"/article")

      assert html =~ "Listing Article"
      assert html =~ articles.title
    end

    test "saves new articles", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/article")

      assert index_live |> element("a", "New Articles") |> render_click() =~
               "New Articles"

      assert_patch(index_live, ~p"/articles/new")

      assert index_live
             |> form("#articles-form", articles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#articles-form", articles: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/articles")

      html = render(index_live)
      assert html =~ "Articles created successfully"
      assert html =~ "some title"
    end

    test "updates articles in listing", %{conn: conn, articles: articles} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("#articles-#{articles.id} a", "Edit") |> render_click() =~
               "Edit Articles"

      assert_patch(index_live, ~p"/articles/#{articles}/edit")

      assert index_live
             |> form("#articles-form", articles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#articles-form", articles: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/articles")

      html = render(index_live)
      assert html =~ "Articles updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes articles in listing", %{conn: conn, articles: articles} do
      {:ok, index_live, _html} = live(conn, ~p"/articles")

      assert index_live |> element("#articles-#{articles.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#articles-#{articles.id}")
    end
  end

  describe "Show" do
    setup [:create_articles]

    test "displays articles", %{conn: conn, articles: articles} do
      {:ok, _show_live, html} = live(conn, ~p"/articles/#{articles}")

      assert html =~ "Show Articles"
      assert html =~ articles.title
    end

    test "updates articles within modal", %{conn: conn, articles: articles} do
      {:ok, show_live, _html} = live(conn, ~p"/articles/#{articles}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Articles"

      assert_patch(show_live, ~p"/articles/#{articles}/show/edit")

      assert show_live
             |> form("#articles-form", articles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#articles-form", articles: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/articles/#{articles}")

      html = render(show_live)
      assert html =~ "Articles updated successfully"
      assert html =~ "some updated title"
    end
  end
end
