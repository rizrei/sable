defmodule SableWeb.WorkoutLive.Index do
  use SableWeb, :live_view

  import SableWeb.TagComponents
  import Ecto.Changeset

  alias Sable.{Repo, Tags, Workouts}
  alias Sable.Workouts.Queries.ListWorkouts.Params

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:actions>
          <.button variant="primary" navigate={~p"/workouts/new"}>
            <.icon name="hero-plus" /> New Workout
          </.button>
        </:actions>
      </.header>

      <.live_component
        module={SableWeb.Workouts.FilterFormComponent}
        id="filter-form"
        form={@form}
        tag_options={@tag_options}
      />

      <.table
        id="workouts"
        rows={@streams.workouts}
        row_click={fn {_id, workout} -> JS.navigate(~p"/workouts/#{workout}") end}
      >
        <:col :let={{_id, workout}} label="Title">{workout.title}</:col>
        <:col :let={{_id, workout}} label="Tags">
          <.tags_list tags={workout.tags} />
        </:col>
        <:col :let={{_id, workout}} label="Exercises">
          {Enum.count(workout.workout_exercises)}
        </:col>
        <:action :let={{_id, workout}}>
          <div class="sr-only">
            <.link navigate={~p"/workouts/#{workout}"}>Show</.link>
          </div>
          <.button
            navigate={~p"/workouts/#{workout}/edit"}
            class="w-10 h-10 flex items-center justify-center bg-blue-500 hover:bg-blue-600 text-white rounded-md shadow-sm"
          >
            <.icon name="hero-pencil-square" class="w-5 h-5" />
          </.button>
        </:action>

        <:action :let={{id, workout}}>
          <.button
            phx-click={JS.push("delete", value: %{id: workout.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
            class="w-10 h-10 flex items-center justify-center bg-red-500 hover:bg-red-600 text-white rounded-md shadow-sm"
          >
            <.icon name="hero-trash" class="w-5 h-5" />
          </.button>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "My Workouts")
      |> assign(:tag_options, tag_options(socket.assigns.current_scope.user))
      |> assign(:form, %Params{} |> Params.changeset() |> to_form(as: :filter))
      |> stream(:workouts, list_workouts())

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    workout = Workouts.get_workout!(id)
    {:ok, _} = Workouts.delete_workout(workout)

    {:noreply, stream_delete(socket, :workouts, workout)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter_params}, socket) do
    case %Params{} |> Params.changeset(filter_params) |> apply_action(:validate) do
      {:ok, params} ->
        {:noreply,
         socket
         |> stream(:workouts, list_workouts(params), reset: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :filter))}
    end
  end

  defp tag_options(user) do
    user
    |> Tags.list_tags()
    |> Enum.map(&{&1.title, &1.id})
  end

  defp list_workouts do
    Workouts.list_workouts() |> Repo.preload([:tags, :workout_exercises])
  end

  defp list_workouts(params) do
    Workouts.list_workouts(params) |> Repo.preload([:tags, :workout_exercises])
  end
end
