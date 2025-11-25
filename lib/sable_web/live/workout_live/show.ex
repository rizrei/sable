defmodule SableWeb.WorkoutLive.Show do
  use SableWeb, :live_view

  alias Sable.{Repo, Workouts}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Workout {@workout.title}
        <:subtitle>This is a workout record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/workouts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/workouts/#{@workout}/edit?&return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit workout
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@workout.title}</:item>
        <:item title="Description">{@workout.description}</:item>
      </.list>

      <hr />
      <h1>Exercises</h1>
      <.table
        id="workout_exercises"
        rows={@streams.workout_exercises}
        row_click={fn {_id, workout_exercise} -> JS.navigate(sets_path(workout_exercise)) end}
      >
        <:col :let={{_id, workout_exercise}} label="Position">{workout_exercise.position}</:col>
        <:col :let={{_id, workout_exercise}} label="Title">{workout_exercise.exercise.title}</:col>
        <:action :let={{_id, workout_exercise}}>
          <.button navigate={sets_path(workout_exercise)}>Add Set</.button>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    workout = Workouts.get_workout!(id) |> Repo.preload(workout_exercises: :exercise)
    workout_exercises = workout.workout_exercises

    {:ok,
     socket
     |> assign(:page_title, "Show Workout")
     |> assign(:workout, workout)
     |> stream(:workout_exercises, workout_exercises)}
  end

  defp sets_path(workout_exercise) do
    ~p"/exercises/#{workout_exercise.exercise_id}/sets/?limit=5&workout_id=#{workout_exercise.workout_id}"
  end
end
