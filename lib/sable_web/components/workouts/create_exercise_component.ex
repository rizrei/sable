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

          <.live_component
            module={SableWeb.Exercises.MetricsLiveSelectComponent}
            id="metrics-live-select"
            field={@form[:metrics]}
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

  def handle_event("cancel_create_exercise", _params, socket) do
    {:noreply, assign(socket, :form, %Exercise{} |> Exercises.change_exercise() |> to_form())}
  end

  def handle_event("save", %{"exercise" => params}, socket) do
    params
    |> Map.put("author_id", get_user_id(socket))
    |> Exercises.create_exercise()
    |> case do
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
