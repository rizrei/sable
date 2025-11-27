defmodule SableWeb.WorkoutLive.Form do
  use SableWeb, :live_view

  alias Sable.Repo
  alias Sable.Workouts
  alias Sable.Workouts.{Workout, WorkoutExercise}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage workout records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="workout-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />

        <LiveSelect.live_select
          id="workout-tag-ids-live-select"
          field={@form[:tag_ids]}
          options={Enum.map(@tags, &{&1.title, &1.id})}
          value={@selected_tag_ids}
          style={:daisyui}
          mode={:tags}
          placeholder="Search for a tag"
          user_defined_options={true}
          dropdown_extra_class="max-h-30 overflow-y-scroll"
          tag_extra_class="badge badge-primary p-1.5 text-sm"
          max_selectable={5}
          update_min_len={1}
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

                <LiveSelect.live_select
                  id={"workout-exercise-id-live-select-#{workout_exercises_form.index}"}
                  field={workout_exercises_form[:exercise_id]}
                  value={workout_exercises_form[:exercise_id].value}
                  options={Enum.map(@exercises, &{&1.title, &1.id})}
                  style={:daisyui}
                  placeholder="Select exercise"
                  dropdown_extra_class="max-h-30 overflow-y-scroll"
                  tag_extra_class="badge badge-primary p-1.5 text-sm"
                  max_selectable={5}
                  update_min_len={1}
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

          <.button
            type="button"
            name="workout[workout_exercises_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            Add Exercise
          </.button>
        </div>

        <div class="flex gap-2 mt-4">
          <.button phx-disable-with="Saving..." variant="primary">Save Workout</.button>
          <.button navigate={return_path(@return_to, @workout)}>Cancel</.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:tags, Sable.Tags.list_tags())
     |> assign(:exercises, Sable.Exercises.Exercise |> Repo.all())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    workout = Workouts.get_workout!(id) |> Repo.preload([:tags, workout_exercises: :exercise])

    socket
    |> assign(:page_title, "Edit Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, Enum.map(workout.tags, & &1.id))
    |> assign(:form, workout_form(workout))
  end

  defp apply_action(socket, :new, _params) do
    workout = %Workout{tags: [], workout_exercises: [%WorkoutExercise{}]}

    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, Enum.map(workout.tags, & &1.id))
    |> assign(:form, workout_form(workout))
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "workout_tag_ids"},
        socket
      ) do
    options = Sable.Tags.search(text) |> Enum.map(&{&1.title, &1.id})

    send_update(LiveSelect.Component, id: id, options: options)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "live_select_change",
        %{"id" => id, "text" => text, "field" => "workout_exercise_id"},
        socket
      ) do
    options = Sable.Exercises.search(text) |> Enum.map(&{&1.title, &1.id})

    send_update(LiveSelect.Component, id: id, options: options)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"workout" => workout_params}, socket) do
    changeset = Workouts.change_workout(socket.assigns.workout, workout_params)

    socket =
      socket
      # |> reorder_workout_exercises(workout_params)
      |> assign(:selected_tag_ids, Map.get(workout_params, "tag_ids", []))
      |> assign(form: to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"workout" => workout_params}, socket) do
    save_workout(socket, socket.assigns.live_action, workout_params)
  end

  defp save_workout(socket, :edit, workout_params) do
    workout_params = maybe_empty_tag_ids(workout_params)

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

  defp save_workout(socket, :new, workout_params) do
    workout_params =
      workout_params
      |> Map.put("author_id", socket.assigns.current_scope.user.id)

    case Workouts.create_workout(workout_params) do
      {:ok, workout} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout created successfully")
         |> push_navigate(to: ~p"/workouts/#{workout}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _workout), do: ~p"/workouts"
  defp return_path("show", workout), do: ~p"/workouts/#{workout}"

  defp maybe_empty_tag_ids(params) when is_map_key(params, "tag_ids_empty_selection"),
    do: Map.put(params, "tag_ids", [])

  defp maybe_empty_tag_ids(params), do: params

  defp workout_form(workout), do: workout |> Workouts.change_workout() |> to_form()

  # defp reorder_workout_exercises(
  #        socket,
  #        %{
  #          "workout_exercises_sort" => sort_order,
  #          "workout_exercises" => workout_exercises
  #        }
  #      ) do
  #   order = Enum.map(sort_order, &workout_exercises[&1]["id"])

  #   socket.assigns.workout.workout_exercises
  #   |> Enum.map(& &1.id)
  #   |> IO.inspect(label: "unordered_ids")

  #   IO.inspect(order, label: "order")

  #   order_fun = &Enum.find_index(order, fn oid -> oid == &1 end)

  #   workout_exercises =
  #     Enum.sort_by(socket.assigns.workout.workout_exercises, &order_fun.(&1.id))

  #   Enum.map(workout_exercises, & &1.id) |> IO.inspect(label: "ordered_ids")

  #   workout =
  #     %{socket.assigns.workout | workout_exercises: workout_exercises}

  #   assign(socket, :workout, workout)
  # end
end
