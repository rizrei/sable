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

        <LiveSelect.live_select
          field={@form[:tag_ids]}
          options={Enum.map(@tags, &{&1.title, &1.id})}
          value={@selected_tag_ids}
          style={:daisyui}
          mode={:tags}
          placeholder="Search for a tag"
          keep_options_on_select
          user_defined_options={true}
          dropdown_extra_class="max-h-60 overflow-y-scroll"
          tag_extra_class="badge badge-primary p-1.5 text-sm"
          max_selectable={5}
          update_min_len={1}
        />

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
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    workout = Workouts.get_workout!(id) |> Repo.preload([:tags, :workout_exercises])

    socket
    |> assign(:page_title, "Edit Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, Enum.map(workout.tags, & &1.id))
    |> assign(:form, workout_form(workout))
  end

  defp apply_action(socket, :new, _params) do
    workout = %Workout{tags: [], workout_exercises: []}

    socket
    |> assign(:page_title, "New Workout")
    |> assign(:workout, workout)
    |> assign(:selected_tag_ids, Enum.map(workout.tags, & &1.id))
    |> assign(:form, workout_form(workout))
  end

  @impl true
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    options =
      Sable.Tags.search(text)
      |> Enum.map(&{&1.title, &1.id})

    send_update(LiveSelect.Component, id: id, options: options)

    {:noreply, socket}
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
end
