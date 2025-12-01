defmodule SableWeb.Workouts.TagsLiveSelectComponent do
  @moduledoc false

  use SableWeb, :live_component

  attr :id, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true
  attr :value, :list, required: true

  def render(%{field: %Phoenix.HTML.FormField{errors: errors}} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(errors, &translate_error(&1)))
      |> assign(:live_select_opts, assigns_to_attributes(assigns, [:errors, :label]))

    ~H"""
    <div class="relative w-full">
      <LiveSelect.live_select
        id={@id}
        field={@field}
        options={@options}
        value={@value}
        style={:daisyui}
        mode={:tags}
        placeholder="Search for a tag"
        keep_options_on_select={true}
        user_defined_options={true}
        dropdown_extra_class="absolute z-50 max-h-30 overflow-y-scroll"
        tag_extra_class="badge badge-primary p-1.5 text-sm"
        max_selectable={5}
        update_min_len={1}
        phx-target={@myself}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
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
