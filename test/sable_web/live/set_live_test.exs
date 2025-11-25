defmodule SableWeb.SetLiveTest do
  use SableWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sable.SetsFixtures

  @create_attrs %{comment: "some comment"}
  @update_attrs %{comment: "some updated comment"}
  @invalid_attrs %{comment: nil}

  setup :register_and_log_in_user

  defp create_set(%{scope: scope}) do
    set = set_fixture(scope)

    %{set: set}
  end

  describe "Index" do
    setup [:create_set]

    test "lists all sets", %{conn: conn, set: set} do
      {:ok, _index_live, html} = live(conn, ~p"/sets")

      assert html =~ "Listing Sets"
      assert html =~ set.comment
    end

    test "saves new set", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Set")
               |> render_click()
               |> follow_redirect(conn, ~p"/sets/new")

      assert render(form_live) =~ "New Set"

      assert form_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#set-form", set: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/sets")

      html = render(index_live)
      assert html =~ "Set created successfully"
      assert html =~ "some comment"
    end

    test "updates set in listing", %{conn: conn, set: set} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#sets-#{set.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/sets/#{set}/edit")

      assert render(form_live) =~ "Edit Set"

      assert form_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#set-form", set: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/sets")

      html = render(index_live)
      assert html =~ "Set updated successfully"
      assert html =~ "some updated comment"
    end

    test "deletes set in listing", %{conn: conn, set: set} do
      {:ok, index_live, _html} = live(conn, ~p"/sets")

      assert index_live |> element("#sets-#{set.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sets-#{set.id}")
    end
  end

  describe "Show" do
    setup [:create_set]

    test "displays set", %{conn: conn, set: set} do
      {:ok, _show_live, html} = live(conn, ~p"/sets/#{set}")

      assert html =~ "Show Set"
      assert html =~ set.comment
    end

    test "updates set and returns to show", %{conn: conn, set: set} do
      {:ok, show_live, _html} = live(conn, ~p"/sets/#{set}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/sets/#{set}/edit?return_to=show")

      assert render(form_live) =~ "Edit Set"

      assert form_live
             |> form("#set-form", set: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#set-form", set: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/sets/#{set}")

      html = render(show_live)
      assert html =~ "Set updated successfully"
      assert html =~ "some updated comment"
    end
  end
end
