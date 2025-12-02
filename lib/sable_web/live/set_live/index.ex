defmodule SableWeb.SetLive.Index do
  use SableWeb, :live_view

  import SableWeb.SetComponents

  alias Sable.Sets
  alias Sets.Set
  alias Contex.{LinePlot, PointPlot, Dataset, Plot}

  @default_limit 5

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@exercise.title}
        <:actions>
          <.button navigate={@return_path}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <div class="column">
        {build_pointplot(@exercise)}
      </div>

      <.set_form form={@form} exercise={@exercise} />
      <.sets_table sets_stream={@streams.sets} metrics={@exercise.metrics} />

      <footer>
        <.button class="btn btn-primary btn-soft w-full" phx-click="load-more">
          <.icon name="hero-plus" /> Load more
        </.button>
      </footer>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Sets.subscribe_sets(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Sets")
     |> assign(:form, new_set_form())}
  end

  def build_pointplot(exercise) do
    params = %{
      type: exercise.metrics |> hd(),
      period: "month",
      shape: Contex.LinePlot,
      exercise: exercise
    }

    %{dataset: dataset, shape: shape} =
      plot_params =
      Sable.Sets.PlotParams.changeset(%Sable.Sets.PlotParams{}, params)
      |> Ecto.Changeset.apply_changes()

    plot =
      Plot.new(dataset, shape, plot_params.width, plot_params.height,
        custom_x_scale: plot_params.custom_x_scale,
        smoothed: plot_params.smoothed
        # custom_x_scale: custom_x_scale
        # custom_y_scale: custom_y_scale
      )
      |> Plot.titles(plot_params.title, nil)

    Plot.to_svg(plot)
  end

  @impl true
  def handle_params(params, uri, socket) do
    sets = Sets.list_sets(socket.assigns.current_scope, params)

    socket =
      socket
      |> assign(:uri, build_uri(uri))
      |> assign(:return_path, return_path(params))
      |> assign(:exercise, Sable.Exercises.get_exercise(params["exercise_id"]))
      |> stream(:sets, sets)

    # |> assign(:chart_options, chart_options())

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    set = Sets.get_set!(socket.assigns.current_scope, id)
    {:ok, _} = Sets.delete_set(socket.assigns.current_scope, set)

    {:noreply, stream_delete(socket, :sets, set)}
  end

  @impl true
  def handle_event("load-more", _params, socket) do
    %{path: path, query: query} = build_uri(socket.assigns.uri)

    {:noreply, push_patch(socket, to: "#{path}?#{query}")}
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
        {:noreply, assign(socket, :form, new_set_form())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:created, %Set{} = set}, socket) do
    socket =
      socket
      |> put_flash(:info, "Set created successfully.")
      |> stream_insert(:sets, set, at: 0)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:deleted, %Set{} = set}, socket) do
    socket =
      socket
      |> put_flash(:info, "Set deleted successfully.")
      |> stream_delete(:sets, set)

    {:noreply, socket}
  end

  defp return_path(%{"workout_id" => workout_id}), do: ~p"/workouts/#{workout_id}"
  defp return_path(_), do: ~p"/my_workouts"

  defp new_set_form, do: %Set{} |> Sets.change_set() |> to_form()

  defp build_uri(uri) when is_binary(uri), do: uri |> URI.parse() |> build_uri()
  defp build_uri(%URI{query: query} = struct), do: %{struct | query: build_url_query(query)}

  defp build_url_query(query) do
    query
    |> URI.decode_query()
    |> Map.update("limit", @default_limit, &(String.to_integer(&1) + @default_limit))
    |> URI.encode_query()
  end
end
