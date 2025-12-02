defmodule SableWeb.SetLive.Index do
  use SableWeb, :live_view

  import SableWeb.SetComponents

  alias Sable.Sets
  alias Sets.Set
  alias Sable.Sets.Plot.Params

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

      <.plot plot={@plot} form={@plot_form} exercise={@exercise} />

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

  def plot(assigns) do
    ~H"""
    <div class="flex gap-2 h-full">
      <div class="w-1/4">
        <.form
          for={@form}
          id="plot-form"
          phx-change="plot_change"
        >
          <.input
            field={@form[:shape]}
            type="select"
            options={Params.shape_options()}
            label="Shape"
          />

          <.input
            field={@form[:period]}
            type="select"
            options={Ecto.Enum.values(Params, :period)}
            label="Period"
          />

          <.input
            field={@form[:type]}
            type="select"
            options={Params.type_options(@exercise)}
            label="Type"
          />
        </.form>
      </div>
      <div :if={@plot} class="flex-1">
        {Contex.Plot.to_svg(@plot)}
      </div>
      <div :if={!@plot} class="flex items-center justify-center h-full w-full text-gray-500">
        Plot unavailable
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, _session, %{assigns: assigns} = socket) do
    exercise = Sable.Exercises.get_exercise(params["exercise_id"])
    plot_params = Sable.Sets.Plot.default_params(exercise)
    plot_form = plot_params |> Sable.Sets.Plot.Params.changeset() |> to_form(as: :plot)

    socket =
      socket
      |> assign(:page_title, "Sets")
      |> assign(:form, new_set_form())
      |> assign(:exercise, exercise)
      |> assign(:plot_params, plot_params)
      |> assign(:plot_form, plot_form)
      |> assign_plot(plot_params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, uri, %{assigns: assigns} = socket) do
    sets = Sets.list_sets(assigns.current_scope, params)

    socket =
      socket
      |> assign(:uri, build_uri(uri))
      |> assign(:return_path, return_path(params))
      |> stream(:sets, sets)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: assigns} = socket) do
    set = Sets.get_set!(assigns.current_scope, id)
    {:ok, _} = Sets.delete_set(assigns.current_scope, set)

    socket =
      socket
      |> put_flash(:info, "Set deleted successfully.")
      |> stream_delete(:sets, set)
      |> assign_plot(assigns.plot_params)

    {:noreply, socket}
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

  @impl true
  def handle_event("plot_change", %{"plot" => params}, %{assigns: assigns} = socket) do
    case assigns.plot_params
         |> Params.changeset(params)
         |> Ecto.Changeset.apply_action(:validate) do
      {:ok, %Params{} = plot_params} ->
        socket =
          socket
          |> assign(:plot_params, plot_params)
          |> assign(:plot_form, plot_params |> Params.changeset() |> to_form(as: :plot))
          |> assign_plot(plot_params)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("save", %{"set" => set_params}, %{assigns: assigns} = socket) do
    set_params =
      set_params
      |> Map.put("user_id", assigns.current_scope.user.id)
      |> Map.put("exercise_id", assigns.exercise.id)

    case Sets.create_set(set_params) do
      {:ok, set} ->
        socket =
          socket
          |> assign(:form, new_set_form())
          |> put_flash(:info, "Set created successfully.")
          |> stream_insert(:sets, set, at: 0)
          |> assign_plot(assigns.plot_params)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

  defp assign_plot(%{assigns: assigns} = socket, plot_params) do
    Sable.Sets.Plot.build(assigns.current_scope.user, assigns.exercise, plot_params)
    |> case do
      %Contex.Plot{} = plot -> assign(socket, :plot, plot)
      _ -> assign(socket, :plot, nil)
    end
  end
end
