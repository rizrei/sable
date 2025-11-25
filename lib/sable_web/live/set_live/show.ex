defmodule SableWeb.SetLive.Show do
  use SableWeb, :live_view

  alias Sable.Sets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Set {@set.id}
        <:subtitle>This is a set record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/sets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/sets/#{@set}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit set
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Comment">{@set.comment}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Sets.subscribe_sets(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Set")
     |> assign(:set, Sets.get_set!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Sable.Sets.Set{id: id} = set},
        %{assigns: %{set: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :set, set)}
  end

  def handle_info(
        {:deleted, %Sable.Sets.Set{id: id}},
        %{assigns: %{set: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current set was deleted.")
     |> push_navigate(to: ~p"/sets")}
  end

  def handle_info({type, %Sable.Sets.Set{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
