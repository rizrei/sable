defmodule SableWeb.Workouts.FilterFormComponent do
  @moduledoc """
  Provides tag components.
  """

  use SableWeb, :live_component

  attr :form, :map, required: true
  attr :tag_options, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="filter-form" phx-change="filter">
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
  def handle_event("live_select_change", %{"id" => id, "text" => text}, socket) do
    options = Sable.Tags.search(text) |> Enum.map(&{&1.title, &1.id})

    send_update(LiveSelect.Component, id: id, options: options)

    {:noreply, socket}
  end
end
