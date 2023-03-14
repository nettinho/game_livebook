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
      <li :for={{pid, %{pos: pos, name: name, target: target, status: status, score: score}} <- @board.players} ><%= inspect({name, pos, status, score}) %> -----> <%= inspect(target) %></li>
    </ul>

    <div style={"width: #{GameEngine.Board.width()}px; height: #{GameEngine.Board.height()}px; border: 2px solid red; position: relative; top: 150px; left: 50px;"}>
      <div :for={{pid, %{pos: {pos_x, pos_y}, name: name, target: target, status: status}} <- @board.players} id={inspect(pid)}
        style={"position: absolute; top: #{pos_y - 8}px; left: #{pos_x - 8}px; width: 16px; height: 16px; border: 3px solid blue; border-radius: 50%;"}
      ></div>

      <div :for={{{x, y}, size} <- @board.fruits} id={"fruit-#{x}-#{y}"}
        style={"position: absolute; top: #{y - size / 2}px; left: #{x - size / 2}px; width: #{size}px; height: #{size}px; border: 4px solid gold; border-radius: 50%;"}
      ></div>
    </div>
    """
  end

  @impl true
  def handle_info({:board_tick, board}, socket) do
    {:noreply, assign(socket, board: board)}
  end
end
