defmodule LivebookWeb.GameLive do
  use LivebookWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Livebook.PubSub, "game")

    socket =
      assign(socket,
        claves: GameServer.view()
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>GAME LIVE</h1>
    <ul>
      <li :for={k <- @claves}><%= inspect(k) %></li>
    </ul>
    <button phx-click="evento">boton</button>
    """
  end

  @impl true
  def handle_event("evento", _, socket) do
    IO.inspect("llamado evento")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:msg, m}, socket) do
    %{claves: claves} = socket.assigns
    {:noreply, assign(socket, claves: [m | claves])}
    # {:noreply, socket}
  end
end
