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
      <li :for={{_pid, %{
        pos: pos,
        name: name,
        target: target,
        status: status,
        score: score}} <- @board.players} >
        <%= inspect({name, pos, status, score}) %> -----> <%= inspect(target) %>
      </li>
    </ul>

    <div style={"width: #{GameEngine.Board.width()}px; height: #{GameEngine.Board.height()}px; border: 2px solid red; position: relative; top: 150px; left: 50px;"}>
      <div
        :for={{pid, player} <- @board.players}
        id={inspect(pid)}
        style={player_style(player)}
      ><%= player.name %></div>

      <div :for={{{x, y}, _} = fruit <- @board.fruits} id={"fruit-#{x}-#{y}"}
        style={fruit_style(fruit)}
      ></div>
    </div>
    """
  end

  defp player_style(%{pos: {pos_x, pos_y}, size: size, color: color}) do
    """
      position: absolute;
      top: #{pos_y - size / 2}px;
      left: #{pos_x - size /2}px;
      width: #{size}px;
      height: #{size}px;
      border: #{size/5}px solid #{color};
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;

      font-size: #{2*(size/3)}px;
      -webkit-text-stroke: #{size/50}px #FFF;
    """
  end

  defp fruit_style({{x, y}, size}) do
    """
      position: absolute;
      top: #{y - size / 2}px;
      left: #{x - size / 2}px;
      width: #{size}px;
      height: #{size}px;
      border: 4px solid gold;
      border-radius: 50%;
    """
  end

  @impl true
  def handle_info({:board_tick, board}, socket) do
    {:noreply, assign(socket, board: board)}
  end
end
