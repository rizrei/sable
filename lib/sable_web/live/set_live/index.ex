defmodule SableWeb.SetLive.Index do
  use SableWeb, :live_view

  alias Sable.Sets
  alias Sets.Set
  alias Sable.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@exercise.title} Sets
        <:actions>
          <.button navigate={@return_path}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="set-form" phx-change="validate" phx-submit="save">
        <.inputs_for :let={metric_form} field={@form[:metrics]}>
          <div class="flex space-x-4">
            <div :for={metric <- @exercise.metrics} class="flex flex-col">
              <.input
                field={metric_form[metric]}
                type="number"
                min="0"
                required={true}
                label={metric}
              />
            </div>
          </div>
        </.inputs_for>

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Set</.button>
        </footer>
      </.form>

      <.table id="sets" rows={@streams.sets}>
        <:col :let={{_id, set}} :for={metric <- @exercise.metrics} label={metric}>
          {Map.get(set.metrics, metric)}
        </:col>
        <:col :let={{_id, set}} label="Created at">{Calendar.strftime(set.inserted_at, "%c")}</:col>
        <:action :let={{id, set}}>
          <.link
            phx-click={JS.push("delete", value: %{id: set.id}) |> hide("##{id}")}
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
  def mount(%{"exercise_id" => exercise_id} = params, _session, socket) do
    if connected?(socket), do: Sets.subscribe_sets(socket.assigns.current_scope)

    exercise =
      Sable.Exercises.Exercise |> Repo.get(exercise_id)

    sets = Sets.list_sets(socket.assigns.current_scope, exercise_id)

    {:ok,
     socket
     |> assign(:page_title, "Listing Sets")
     |> assign(:return_path, return_path(params))
     |> assign(:form, to_form(Sets.change_set(%Sable.Sets.Set{})))
     |> assign(:exercise, exercise)
     |> stream(:sets, sets)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    set = Sets.get_set!(socket.assigns.current_scope, id)
    {:ok, _} = Sets.delete_set(socket.assigns.current_scope, set)

    {:noreply, stream_delete(socket, :sets, set)}
  end

  @impl true
  def handle_event("validate", %{"set" => set_params}, socket) do
    changeset = Sets.change_set(%Set{}, set_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"set" => set_params}, socket) do
    set_params =
      set_params
      |> Map.put("user_id", socket.assigns.current_scope.user.id)
      |> Map.put("exercise_id", socket.assigns.exercise.id)

    case Sets.create_set(socket.assigns.current_scope, set_params) do
      {:ok, _set} ->
        {:noreply,
         socket
         |> assign(:form, to_form(Sets.change_set(%Sable.Sets.Set{})))
         |> put_flash(:info, "Set created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:created, %Sable.Sets.Set{} = set}, socket) do
    socket =
      socket
      |> put_flash(:info, "Set created successfully.")
      |> stream_insert(:sets, set, at: 0)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:deleted, %Sable.Sets.Set{} = set}, socket) do
    socket =
      socket
      |> put_flash(:info, "Set deleted successfully.")
      |> stream_delete(:sets, set)

    {:noreply, socket}
  end

  defp return_path(%{"workout_id" => workout_id}), do: ~p"/workouts/#{workout_id}"
  defp return_path(_), do: ~p"/workouts"
end
