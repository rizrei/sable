defmodule SableWeb.SetComponents do
  @moduledoc false

  use SableWeb, :live_component

  attr :exercise, Sable.Exercises.Exercise, required: true
  attr :form, Phoenix.HTML.Form, required: true

  def set_form(assigns) do
    ~H"""
    <.form for={@form} id="set-form" phx-change="validate" phx-submit="save">
      <.inputs_for :let={metric_form} field={@form[:metrics]}>
        <div class="flex gap-2">
          <div :for={metric <- @exercise.metrics} class="flex-1">
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

      <.button
        class="btn btn-primary btn-soft w-full"
        phx-disable-with="Saving..."
        variant="primary"
      >
        Save Set
      </.button>
    </.form>
    """
  end

  attr :metrics, :list, required: true, doc: "Exercise metrics list"
  attr :sets_stream, :map, required: true

  def sets_table(assigns) do
    ~H"""
    <.table id="sets" rows={@sets_stream}>
      <:col :let={{_id, set}} :for={metric <- @metrics} label={metric}>
        {Map.get(set.metrics, metric)}
      </:col>
      <:col :let={{_id, set}} label="Created at">{Calendar.strftime(set.inserted_at, "%c")}</:col>
      <:action :let={{id, set}}>
        <.button
          phx-click={JS.push("delete", value: %{id: set.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
          class="w-10 h-10 flex items-center justify-center bg-red-500 hover:bg-red-600 text-white rounded-md shadow-sm"
        >
          <.icon name="hero-trash" class="w-5 h-5" />
        </.button>
      </:action>
    </.table>
    """
  end
end
