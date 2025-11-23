defmodule SableWeb.WorkoutLive.Index do
  use SableWeb, :live_view

  alias Sable.Workouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Workouts
        <:actions>
          <.button variant="primary" navigate={~p"/workouts/new"}>
            <.icon name="hero-plus" /> New Workout
          </.button>
        </:actions>
      </.header>

      <.table
        id="workouts"
        rows={@streams.workouts}
        row_click={fn {_id, workout} -> JS.navigate(~p"/workouts/#{workout}") end}
      >
        <:col :let={{_id, workout}} label="Title">{workout.title}</:col>
        <:col :let={{_id, workout}} label="Description">{workout.description}</:col>
        <:action :let={{_id, workout}}>
          <div class="sr-only">
            <.link navigate={~p"/workouts/#{workout}"}>Show</.link>
          </div>
          <.link navigate={~p"/workouts/#{workout}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, workout}}>
          <.link
            phx-click={JS.push("delete", value: %{id: workout.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Workouts")
     |> stream(:workouts, list_workouts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    workout = Workouts.get_workout!(id)
    {:ok, _} = Workouts.delete_workout(workout)

    {:noreply, stream_delete(socket, :workouts, workout)}
  end

  defp list_workouts() do
    Workouts.list_workouts()
  end
end
