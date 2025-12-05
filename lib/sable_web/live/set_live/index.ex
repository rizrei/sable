defmodule SableWeb.SetLive.Index do
  use SableWeb, :live_view

  import SableWeb.SetComponents

  alias Sable.Sets
  alias Sets.{Plot, Set}

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

      <.set_plot plot={@plot} form={@plot_form} />
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
  def mount(params, _session, %{assigns: assigns} = socket) do
    exercise = Sable.Exercises.get_exercise(params["exercise_id"])
    plot = build_plot(exercise, assigns.current_scope.user)

    socket =
      socket
      |> assign(:page_title, "Sets")
      |> assign(:form, new_set_form())
      |> assign(:exercise, exercise)
      |> assign(:plot, plot)
      |> assign(:plot_form, to_form(Plot.changeset(plot), as: :plot))

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

    IO.inspect(set, label: "Deleted set")

    socket =
      socket
      |> put_flash(:info, "Set deleted successfully.")
      |> stream_delete(:sets, set)
      |> change_plot(set, :remove)

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
    case assigns.plot
         |> Plot.changeset(params)
         |> Ecto.Changeset.apply_action(:validate) do
      {:ok, %Plot{} = plot} ->
        {:noreply, assign(socket, :plot, plot)}

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
          |> change_plot(set, :add)

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

  defp build_plot(exercise, user) do
    %Plot{exercise: exercise, user: user}
    |> Plot.changeset()
    |> Ecto.Changeset.apply_action!(:validate)
  end

  defp change_plot(socket, set, :add) do
    socket
    |> update(:plot, fn plot ->
      plot
      |> Plot.sets_list_changeset(%{sets_list: plot.sets_list ++ [set]})
      |> Ecto.Changeset.apply_action!(:validate)
    end)
  end

  defp change_plot(socket, %Set{id: set_id}, :remove) do
    socket
    |> update(:plot, fn plot ->
      plot
      |> Plot.sets_list_changeset(%{
        sets_list: Enum.reject(plot.sets_list, fn %{id: id} -> id == set_id end)
      })
      |> Ecto.Changeset.apply_action!(:validate)
    end)
  end
end
