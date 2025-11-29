defmodule SableWeb.Workouts.CreateExerciseComponent do
  @moduledoc false

  use SableWeb, :live_component

  alias Sable.Exercises
  alias Sable.Exercises.Exercise

  attr :current_scope, Sable.Accounts.Scope
  attr :show?, :boolean, required: true

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:modal_id, fn -> "create-exercise-modal" end)
      |> assign_new(:form, fn -> %Exercise{} |> Exercises.change_exercise() |> to_form() end)

    ~H"""
    <div>
      <.modal
        id={@modal_id}
        show={@show?}
        on_cancel={JS.push("cancel_create_exercise", target: @myself)}
      >
        <.form
          for={@form}
          id="exercise-form"
          class="flex flex-col space-y-2"
          phx-change="validate"
          phx-submit="save"
          phx-target={@myself}
        >
          <.input
            field={@form[:title]}
            type="text"
            placeholder="Title"
            autocomplete="off"
          />

          <LiveSelect.live_select
            id="new-exercise-form-live-select"
            field={@form[:metrics]}
            mode={:tags}
            style={:daisyui}
            placeholder="Metrics"
            options={Ecto.Enum.values(Exercise, :metrics)}
            keep_options_on_select={true}
            dropdown_extra_class="max-h-30 overflow-y-scroll"
            tag_extra_class="badge badge-primary p-1.5 text-sm"
            max_selectable={5}
            update_min_len={1}
            phx-target={@myself}
          />

          <.button type="submit">Save Exercise</.button>
          <.button
            type="button"
            phx-click={
              @modal_id
              |> hide_modal()
              |> JS.push("cancel_create_exercise", target: @myself)
            }
          >
            Cancel
          </.button>
        </.form>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"exercise" => exercise_params}, socket) do
    form = %Exercise{} |> Exercises.change_exercise(exercise_params) |> to_form(action: :validate)
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("live_select_change", %{"field" => "exercise_metrics"}, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel_create_exercise", _params, socket) do
    {:noreply, assign(socket, :form, %Exercise{} |> Exercises.change_exercise() |> to_form())}
  end

  def handle_event("save", %{"exercise" => params}, socket) do
    exercise_params =
      params
      |> Map.put("author_id", get_user_id(socket))

    case Exercises.create_exercise(exercise_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_event("close_modal", %{to: "#close-modal-btn-create-exercise-modal"})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp get_user_id(%{assigns: %{current_scope: %{user: %{id: id}}}}), do: id
  defp get_user_id(_), do: nil
end
