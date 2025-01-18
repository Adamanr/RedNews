defmodule RednewsWeb.HeadlinesLiveTest do
  use RednewsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rednews.PostsFixtures

  @create_attrs %{header: "some header", title: "some title", category: ["option1", "option2"], content: "some content", is_fake: true, additional: %{}, important: 42, is_very_important: true, tags: ["option1", "option2"]}
  @update_attrs %{header: "some updated header", title: "some updated title", category: ["option1"], content: "some updated content", is_fake: false, additional: %{}, important: 43, is_very_important: false, tags: ["option1"]}
  @invalid_attrs %{header: nil, title: nil, category: [], content: nil, is_fake: false, additional: nil, important: nil, is_very_important: false, tags: []}

  defp create_headlines(_) do
    headlines = headlines_fixture()
    %{headlines: headlines}
  end

  describe "Index" do
    setup [:create_headlines]

    test "lists all headlines", %{conn: conn, headlines: headlines} do
      {:ok, _index_live, html} = live(conn, ~p"/headlines")

      assert html =~ "Listing Headlines"
      assert html =~ headlines.header
    end

    test "saves new headlines", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/headlines")

      assert index_live |> element("a", "New Headlines") |> render_click() =~
               "New Headlines"

      assert_patch(index_live, ~p"/headlines/new")

      assert index_live
             |> form("#headlines-form", headlines: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#headlines-form", headlines: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/headlines")

      html = render(index_live)
      assert html =~ "Headlines created successfully"
      assert html =~ "some header"
    end

    test "updates headlines in listing", %{conn: conn, headlines: headlines} do
      {:ok, index_live, _html} = live(conn, ~p"/headlines")

      assert index_live |> element("#headlines-#{headlines.id} a", "Edit") |> render_click() =~
               "Edit Headlines"

      assert_patch(index_live, ~p"/headlines/#{headlines}/edit")

      assert index_live
             |> form("#headlines-form", headlines: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#headlines-form", headlines: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/headlines")

      html = render(index_live)
      assert html =~ "Headlines updated successfully"
      assert html =~ "some updated header"
    end

    test "deletes headlines in listing", %{conn: conn, headlines: headlines} do
      {:ok, index_live, _html} = live(conn, ~p"/headlines")

      assert index_live |> element("#headlines-#{headlines.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#headlines-#{headlines.id}")
    end
  end

  describe "Show" do
    setup [:create_headlines]

    test "displays headlines", %{conn: conn, headlines: headlines} do
      {:ok, _show_live, html} = live(conn, ~p"/headlines/#{headlines}")

      assert html =~ "Show Headlines"
      assert html =~ headlines.header
    end

    test "updates headlines within modal", %{conn: conn, headlines: headlines} do
      {:ok, show_live, _html} = live(conn, ~p"/headlines/#{headlines}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Headlines"

      assert_patch(show_live, ~p"/headlines/#{headlines}/show/edit")

      assert show_live
             |> form("#headlines-form", headlines: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#headlines-form", headlines: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/headlines/#{headlines}")

      html = render(show_live)
      assert html =~ "Headlines updated successfully"
      assert html =~ "some updated header"
    end
  end
end
