defmodule RednewsWeb.ChannelsLiveTest do
  use RednewsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Rednews.AccountsFixtures

  @create_attrs %{
    links: "some links",
    name: "some name",
    header: "some header",
    desc: "some desc",
    category: ["option1", "option2"],
    is_verificated: true,
    logo: "some logo",
    additional: %{},
    stars: 42
  }
  @update_attrs %{
    links: "some updated links",
    name: "some updated name",
    header: "some updated header",
    desc: "some updated desc",
    category: ["option1"],
    is_verificated: false,
    logo: "some updated logo",
    additional: %{},
    stars: 43
  }
  @invalid_attrs %{
    links: nil,
    name: nil,
    header: nil,
    desc: nil,
    category: [],
    is_verificated: false,
    logo: nil,
    additional: nil,
    stars: nil
  }

  defp create_channels(_) do
    channels = channels_fixture()
    %{channels: channels}
  end

  describe "Index" do
    setup [:create_channels]

    test "lists all channel", %{conn: conn, channels: channels} do
      {:ok, _index_live, html} = live(conn, ~p"/channel")

      assert html =~ "Listing Channel"
      assert html =~ channels.links
    end

    test "saves new channels", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/channel")

      assert index_live |> element("a", "New Channels") |> render_click() =~
               "New Channels"

      assert_patch(index_live, ~p"/channel/new")

      assert index_live
             |> form("#channels-form", channels: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#channels-form", channels: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/channel")

      html = render(index_live)
      assert html =~ "Channels created successfully"
      assert html =~ "some links"
    end

    test "updates channels in listing", %{conn: conn, channels: channels} do
      {:ok, index_live, _html} = live(conn, ~p"/channel")

      assert index_live |> element("#channel-#{channels.id} a", "Edit") |> render_click() =~
               "Edit Channels"

      assert_patch(index_live, ~p"/channel/#{channels}/edit")

      assert index_live
             |> form("#channels-form", channels: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#channels-form", channels: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/channel")

      html = render(index_live)
      assert html =~ "Channels updated successfully"
      assert html =~ "some updated links"
    end

    test "deletes channels in listing", %{conn: conn, channels: channels} do
      {:ok, index_live, _html} = live(conn, ~p"/channel")

      assert index_live |> element("#channel-#{channels.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#channel-#{channels.id}")
    end
  end

  describe "Show" do
    setup [:create_channels]

    test "displays channels", %{conn: conn, channels: channels} do
      {:ok, _show_live, html} = live(conn, ~p"/channel/#{channels}")

      assert html =~ "Show Channels"
      assert html =~ channels.links
    end

    test "updates channels within modal", %{conn: conn, channels: channels} do
      {:ok, show_live, _html} = live(conn, ~p"/channel/#{channels}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Channels"

      assert_patch(show_live, ~p"/channel/#{channels}/show/edit")

      assert show_live
             |> form("#channels-form", channels: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#channels-form", channels: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/channel/#{channels}")

      html = render(show_live)
      assert html =~ "Channels updated successfully"
      assert html =~ "some updated links"
    end
  end
end
