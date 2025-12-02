defmodule SableWeb.Exercises.MetricsLiveSelectComponent do
  @moduledoc false

  use SableWeb, :live_component

  attr :field, Phoenix.HTML.FormField, required: true

  def render(%{field: %Phoenix.HTML.FormField{errors: errors}} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(errors, &translate_error(&1)))
      |> assign(:live_select_opts, assigns_to_attributes(assigns, [:errors, :label]))

    ~H"""
    <div class="relative w-full">
      <LiveSelect.live_select
        id="new-exercise-form-live-select"
        field={@field}
        mode={:tags}
        style={:daisyui}
        placeholder="Metrics"
        options={Ecto.Enum.values(Sable.Exercises.Exercise, :metrics)}
        keep_options_on_select={true}
        dropdown_extra_class="absolute z-50 max-h-30 overflow-y-scroll"
        tag_extra_class="badge badge-primary p-1.5 text-sm"
        text_input_extra_class={[@errors != [] && "input-error"]}
        max_selectable={5}
        update_min_len={1}
        phx-target={@myself}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @impl true
  def handle_event("live_select_change", %{"field" => "exercise_metrics"}, socket) do
    {:noreply, socket}
  end
end
