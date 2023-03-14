defmodule LivebookWeb.GameLive do
  use LivebookWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Livebook.PubSub, "board_tick")

    socket = assign(socket, board: GameServer.view())
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>GAME LIVE</h1>
    <ul>
      <li :for={{pid, %{pos: pos, name: name, target: target, status: status}} <- @board.players} ><%= inspect({name, pos, status}) %> -----> <%= inspect(target) %></li>
    </ul>

    <div style="width: 500px; height: 500px; border: 2px solid red; position: absolute; top: 150px; left: 50px;">
      <div :for={{pid, %{pos: {pos_x, pos_y}, name: name, target: target, status: status}} <- @board.players} id={inspect(pid)}
        style={"position: relative; top: #{pos_y}px; left: #{pos_x}px; width: 15px; height: 15px; border: 3px solid blue; border-radius: 50%;"}


      ></div>
    </div>
    """
  end

  @impl true
  def handle_info({:board_tick, board}, socket) do
    {:noreply, assign(socket, board: board)}
  end
end
