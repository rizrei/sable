defmodule SableWeb.Workouts.FilterComponent do
  @moduledoc """
  Workout filter component.
  """

  use SableWeb, :live_component

  alias Sable.Workouts.Queries.ListWorkouts.Params, as: ListWorkoutsParams
  alias Sable.Tags.Queries.ListTags.Params, as: ListTagsParams

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="filter" phx-change="filter_change" phx-target={@myself}>
        <div class="flex items-center space-x-2">
          <.inputs_for :let={filter} field={@form[:filter]}>
            <div class="flex-2">
              <.input
                field={filter[:search]}
                type="search"
                placeholder="Search..."
                autocomplete="off"
                phx-debounce={200}
              />
            </div>

            <div class="fieldset flex-1 mb-2 relative">
              <LiveSelect.live_select
                id="workout-tag-ids-live-select"
                field={filter[:tag_id]}
                options={@tag_options}
                style={:daisyui}
                mode={:tags}
                placeholder="Search for a tag"
                keep_options_on_select={true}
                dropdown_extra_class="absolute z-50 max-h-60 overflow-y-scroll"
                tag_extra_class="badge badge-primary p-1.5 text-sm"
                max_selectable={5}
                update_min_len={1}
                phx-target={@myself}
              />
            </div>
          </.inputs_for>

          <div class="fieldset mb-2">
            <.button navigate={~p"/my_workouts"}>Reset</.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    form = %ListWorkoutsParams{} |> ListWorkoutsParams.changeset() |> to_form(as: :filter)

    {:ok,
     socket
     |> assign(:form, form)}
  end

  @impl true
  def update(assigns, socket) do
    tag_options = tag_options(%{filter: %{user_id: assigns.current_scope.user.id}})

    {:ok,
     socket
     |> assign(:current_scope, assigns.current_scope)
     |> assign(:tag_options, tag_options)}
  end

  @impl true
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    tag_options =
      tag_options(%{filter: %{user_id: socket.assigns.current_scope.user.id, search: text}})

    send_update(LiveSelect.Component, id: id, options: tag_options)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_change", %{"filter" => filter_params}, socket) do
    case validate_filter_params(filter_params) do
      {:ok, %ListWorkoutsParams{} = params} ->
        send(self(), {:filter_change, params})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :filter))}
    end
  end

  def validate_filter_params(params) do
    %ListWorkoutsParams{}
    |> ListWorkoutsParams.changeset(params)
    |> Ecto.Changeset.apply_action(:validate)
  end

  defp tag_options(params) do
    %ListTagsParams{}
    |> ListTagsParams.changeset(params)
    |> Ecto.Changeset.apply_changes()
    |> Sable.Tags.list_tags()
    |> Enum.map(&{&1.title, &1.id})
  end
end
