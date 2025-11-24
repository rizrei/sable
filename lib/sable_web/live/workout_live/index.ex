defmodule SableWeb.WorkoutLive.Index do
  use SableWeb, :live_view

  import SableWeb.TagComponents

  alias Sable.{Repo, Workouts}

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
        <:col :let={{_id, workout}} label="Tags">
          <.tags_list tags={workout.tags} />
        </:col>
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
     |> stream(:workouts, Workouts.list_workouts() |> Repo.preload([:tags]))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    workout = Workouts.get_workout!(id)
    {:ok, _} = Workouts.delete_workout(workout)

    {:noreply, stream_delete(socket, :workouts, workout)}
  end
end
