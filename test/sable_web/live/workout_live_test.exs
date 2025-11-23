defmodule SableWeb.WorkoutLiveTest do
  use SableWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sable.WorkoutsFixtures

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}
  defp create_workout(_) do
    workout = workout_fixture()

    %{workout: workout}
  end

  describe "Index" do
    setup [:create_workout]

    test "lists all workouts", %{conn: conn, workout: workout} do
      {:ok, _index_live, html} = live(conn, ~p"/workouts")

      assert html =~ "Listing Workouts"
      assert html =~ workout.title
    end

    test "saves new workout", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/workouts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Workout")
               |> render_click()
               |> follow_redirect(conn, ~p"/workouts/new")

      assert render(form_live) =~ "New Workout"

      assert form_live
             |> form("#workout-form", workout: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#workout-form", workout: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/workouts")

      html = render(index_live)
      assert html =~ "Workout created successfully"
      assert html =~ "some title"
    end

    test "updates workout in listing", %{conn: conn, workout: workout} do
      {:ok, index_live, _html} = live(conn, ~p"/workouts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#workouts-#{workout.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/workouts/#{workout}/edit")

      assert render(form_live) =~ "Edit Workout"

      assert form_live
             |> form("#workout-form", workout: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#workout-form", workout: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/workouts")

      html = render(index_live)
      assert html =~ "Workout updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes workout in listing", %{conn: conn, workout: workout} do
      {:ok, index_live, _html} = live(conn, ~p"/workouts")

      assert index_live |> element("#workouts-#{workout.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#workouts-#{workout.id}")
    end
  end

  describe "Show" do
    setup [:create_workout]

    test "displays workout", %{conn: conn, workout: workout} do
      {:ok, _show_live, html} = live(conn, ~p"/workouts/#{workout}")

      assert html =~ "Show Workout"
      assert html =~ workout.title
    end

    test "updates workout and returns to show", %{conn: conn, workout: workout} do
      {:ok, show_live, _html} = live(conn, ~p"/workouts/#{workout}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/workouts/#{workout}/edit?return_to=show")

      assert render(form_live) =~ "Edit Workout"

      assert form_live
             |> form("#workout-form", workout: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#workout-form", workout: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/workouts/#{workout}")

      html = render(show_live)
      assert html =~ "Workout updated successfully"
      assert html =~ "some updated title"
    end
  end
end
