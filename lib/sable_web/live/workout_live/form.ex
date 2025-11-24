defmodule SableWeb.WorkoutLive.Form do
  use SableWeb, :live_view

  alias Sable.Repo
  alias Sable.Workouts
  alias Sable.Workouts.Workout

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

        <div id="tags-inputs">
          <.inputs_for :let={workout_tag} field={@form[:workout_tags]}>
            <div class="flex items-center mt-4 mb-2 space-x-2">
              <input type="hidden" name="workout[workout_tags_sort][]" value={workout_tag.index} />
              <.input
                field={workout_tag[:tag_id]}
                type="select"
                label="Tag"
                options={Enum.map(@tags, &{&1.title, &1.id})}
              />
              <button
                type="button"
                name="workout[workout_tags_drop][]"
                value={workout_tag.index}
                phx-click={JS.dispatch("change")}
              >
                <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
              </button>
            </div>
          </.inputs_for>

          <input type="hidden" name="workout[workout_tags_drop][]" />

          <.button
            type="button"
            name="workout[workout_tags_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
          >
            Add Tag
          </.button>
        </div>

        <div id="exercises-inputs">
          <.inputs_for :let={workout_exercise} field={@form[:workout_exercises]}>
            <div class="flex items-center mt-4 mb-2 space-x-2">
              <input
                type="hidden"
                name="workout[workout_exercises_sort][]"
                value={workout_exercise.index}
              />

              <%!-- <.input
                field={workout_exercise[:position]}
                type="number"
                label="Position"
                required="true"
              /> --%>

              <.input
                field={workout_exercise[:exercise_id]}
                type="select"
                label="Exercise"
                options={Enum.map(@exercises, &{&1.title, &1.id})}
              />
              <button
                type="button"
                name="workout[workout_exercises_drop][]"
                value={workout_exercise.index}
                phx-click={JS.dispatch("change")}
              >
                <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
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

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Workout</.button>
          <.button navigate={return_path(@return_to, @workout)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    workout = Workouts.get_workout!(id) |> Repo.preload(:tags)

    socket
    |> assign(:page_title, "Edit Workout")
    |> assign(:workout, workout)
    |> assign(:tags, Sable.Tag |> Repo.all())
    |> assign(:form, workout |> Workouts.change_workout() |> to_form())
  end

  defp apply_action(socket, :new, _params) do
    workout = %Workout{workout_tags: [], workout_exercises: []}

    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, workout)
    |> assign(:tags, Sable.Tag |> Repo.all())
    |> assign(:exercises, Sable.Exercises.Exercise |> Repo.all())
    |> assign(:form, workout |> Workouts.change_workout() |> to_form())
  end

  @impl true
  def handle_event("validate", %{"workout" => workout_params}, socket) do
    changeset = Workouts.change_workout(socket.assigns.workout, workout_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"workout" => workout_params}, socket) do
    IO.inspect(socket.assigns[:current_user])
    # workout_params = Map.put(workout_params, "author_id", socket.assigns.current_user.id)

    {:noreply, socket}
    # save_workout(socket, socket.assigns.live_action, workout_params)
  end

  defp save_workout(socket, :edit, workout_params) do
    case Workouts.update_workout(socket.assigns.workout, workout_params) do
      {:ok, workout} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, workout))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_workout(socket, :new, workout_params) do
    IO.inspect(socket.assigns.current_user)
    workout_params = Map.put(workout_params, "author_id", socket.assigns.current_user.id)

    case Workouts.create_workout(workout_params) do
      {:ok, workout} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, workout))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _workout), do: ~p"/workouts"
  defp return_path("show", workout), do: ~p"/workouts/#{workout}"
end
