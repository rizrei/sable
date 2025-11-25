defmodule SableWeb.SetLive.Form do
  use SableWeb, :live_view

  alias Sable.Sets
  alias Sable.Sets.Set

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage set records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="set-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:comment]} type="textarea" label="Comment" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Set</.button>
          <.button navigate={return_path(@current_scope, @return_to, @set)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    set = Sets.get_set!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Set")
    |> assign(:set, set)
    |> assign(:form, to_form(Sets.change_set(socket.assigns.current_scope, set)))
  end

  defp apply_action(socket, :new, _params) do
    set = %Set{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Set")
    |> assign(:set, set)
    |> assign(:form, to_form(Sets.change_set(socket.assigns.current_scope, set)))
  end

  @impl true
  def handle_event("validate", %{"set" => set_params}, socket) do
    changeset = Sets.change_set(socket.assigns.set, set_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"set" => set_params}, socket) do
    save_set(socket, socket.assigns.live_action, set_params)
  end

  defp save_set(socket, :edit, set_params) do
    case Sets.update_set(socket.assigns.current_scope, socket.assigns.set, set_params) do
      {:ok, set} ->
        {:noreply,
         socket
         |> put_flash(:info, "Set updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, set)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_set(socket, :new, set_params) do
    case Sets.create_set(socket.assigns.current_scope, set_params) do
      {:ok, set} ->
        {:noreply,
         socket
         |> put_flash(:info, "Set created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, set)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _set), do: ~p"/sets"
  defp return_path(_scope, "show", set), do: ~p"/sets/#{set}"
end
