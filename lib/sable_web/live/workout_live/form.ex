defmodule SableWeb.WorkoutLive.Form do
  use SableWeb, :live_view

  alias Sable.Exercises
  alias Sable.Exercises.Exercise
  alias Sable.{Repo, Tags, Workouts}
  alias Sable.Workouts.{Workout, WorkoutExercise}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form
        for={@form}
        id="workout-form"
        class="flex flex-col space-y-2"
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" required={true} />
        <.input field={@form[:description]} type="textarea" label="Description" />

        <.live_component
          id="workout-tag-ids-live-select"
          module={SableWeb.Workouts.TagsLiveSelectComponent}
          options={Enum.map(@tags, &{&1.title, &1.id})}
          field={@form[:tag_ids]}
          value={@selected_tag_ids}
        />

        <div id="workout-exercises-inputs" phx-hook="SortableInputsFor">
          <.inputs_for :let={workout_exercises_form} field={@form[:workout_exercises]}>
            <div class="flex items-center mt-4 mb-2 space-x-2">
              <div class="flex items-center space-x-2">
                <.icon name="hero-bars-3" class="cursor-pointer relative w-5 h-5" />
                <div class="h-5 leading-5">{workout_exercises_form.index + 1}</div>
                <.input
                  hidden={true}
                  field={workout_exercises_form[:position]}
                  value={workout_exercises_form.index + 1}
                />
              </div>

              <div class="grow">
                <input
                  type="hidden"
                  name="workout[workout_exercises_sort][]"
                  value={workout_exercises_form.index}
                />

                <.live_component
                  id={"workout-exercise-id-live-select-#{workout_exercises_form.id}"}
                  module={SableWeb.Workouts.ExerciseLiveSelectComponent}
                  field={workout_exercises_form[:exercise_id]}
                  options={Enum.map(@exercises, &{&1.title, &1.id})}
                />
              </div>

              <button
                type="button"
                name="workout[workout_exercises_drop][]"
                value={workout_exercises_form.index}
                phx-click={JS.dispatch("change")}
                class="flex items-center justify-center"
              >
                <.icon name="hero-x-mark" class="w-6 h-6" />
              </button>
            </div>
          </.inputs_for>

          <input type="hidden" name="workout[workout_exercises_drop][]" />

          <div class="flex justify-between gap-2">
            <.button
              type="button"
              name="workout[workout_exercises_sort][]"
              value="new"
              phx-click={JS.dispatch("change")}
              class="btn btn-primary btn-soft flex-1"
            >
              Add Exercise
            </.button>

            <.button
              type="button"
              phx-click={show_modal("create-exercise-modal")}
              class="btn btn-primary btn-soft flex-1"
            >
              Create Exercise
            </.button>
          </div>
        </div>

        <.button phx-disable-with="Saving...">Save Workout</.button>
        <.button navigate={@return_path}>Cancel</.button>
      </.form>

      <.live_component
        module={SableWeb.Workouts.CreateExerciseComponent}
        id="create-exercise"
        show?={@show_exercise_form?}
        current_scope={@current_scope}
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: Exercises.subscribe_exercises()

    {:ok,
     socket
     |> assign(:return_path, return_path(params))
     |> assign(:tags, Tags.list_tags())
     |> assign(:exercises, Exercises.list_exercises(limit: 25))
     |> assign(:show_exercise_form?, false)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    workout = Workouts.get_workout!(id) |> Repo.preload([:tags, workout_exercises: :exercise])

    socket
    |> assign(:page_title, "Edit Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, Enum.map(workout.tags, & &1.id))
    |> assign(:form, workout |> Workouts.change_workout() |> to_form())
  end

  defp apply_action(socket, :new, _params) do
    workout = %Workout{tags: [], workout_exercises: [%WorkoutExercise{}]}

    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, [])
    |> assign(:form, workout |> Workouts.change_workout() |> to_form())
  end

  @impl true
  def handle_event("validate", %{"workout" => workout_params}, socket) do
    changeset = Workouts.change_workout(socket.assigns.workout, workout_params)

    socket =
      socket
      |> assign(:selected_tag_ids, Map.get(workout_params, "tag_ids", []))
      |> assign(form: to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"workout" => params}, %{assigns: %{live_action: :new}} = socket) do
    workout_params =
      params
      |> Map.put("author_id", socket.assigns.current_scope.user.id)

    case Workouts.create_workout(workout_params) do
      {:ok, %{workout: workout}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout created successfully")
         |> push_navigate(to: ~p"/workouts/#{workout}")}

      {:error, :workout, %Ecto.Changeset{} = changeset, _} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("save", %{"workout" => params}, %{assigns: %{live_action: :edit}} = socket) do
    workout_params = maybe_empty_tag_ids(params)

    case Workouts.update_workout(socket.assigns.workout, workout_params) do
      {:ok, workout} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout updated successfully")
         |> push_navigate(to: ~p"/workouts/#{workout}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:created, %Exercise{} = exercise}, socket) do
    socket =
      socket
      |> update(:exercises, &Enum.sort_by([exercise | &1], fn e -> e.title end))
      |> put_flash(:info, "Exercise created successfully")

    {:noreply, socket}
  end

  defp return_path(%{"return_to" => "show", "id" => id}), do: ~p"/workouts/#{id}"
  defp return_path(_), do: ~p"/my_workouts"

  defp maybe_empty_tag_ids(params) when is_map_key(params, "tag_ids_empty_selection"),
    do: Map.put(params, "tag_ids", [])

  defp maybe_empty_tag_ids(params), do: params
end
