defmodule SableWeb.WorkoutLive.Show do
  use SableWeb, :live_view

  alias Sable.Workouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Workout {@workout.id}
        <:subtitle>This is a workout record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/workouts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/workouts/#{@workout}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit workout
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@workout.title}</:item>
        <:item title="Description">{@workout.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Workout")
     |> assign(:workout, Workouts.get_workout!(id))}
  end
end
