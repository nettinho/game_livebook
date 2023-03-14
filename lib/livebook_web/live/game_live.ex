defmodule LivebookWeb.GameLive do
  use LivebookWeb, :game_live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Livebook.PubSub, "board_tick")

    socket = assign(socket, board: GameServer.view())
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style={page_style()}>
      <h1 class="text-6xl p-16 text-center font-mono">Elixir adventure</h1>

      <div class="flex">
        <div>
          <div
            :for={
              {_pid,
               %{
                 name: name,
                 score: score,
                 powered: powered,
                 status: status
               }} <- Enum.sort_by(@board.players, fn {_, %{score: score}} -> score end, :desc)
            }
            class="p-2 m-2 border border-slate-500 rounded-md font-mono"
          >
            <span class="inline-block w-24"><%= score %></span>
            <span class="inline-block w-16"><%= inspect(status) %></span>
            <span class="inline-block w-16"><%= name %></span>
            <span class="inline-block w-16"><%= powered %></span>
          </div>
        </div>
        <div style={arena_style()}>
          <div :for={{pid, player} <- @board.players} id={inspect(pid)} style={player_style(player)}>
            <span style={"position: relative; bottom: -#{player.size}px"}><%= player.name %></span>
          </div>

          <div
            :for={{{x, y}, _} = fruit <- @board.fruits}
            id={"fruit-#{x}-#{y}"}
            style={fruit_style(fruit)}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp page_style do
    """
      width: 100%;
      background: black;
      color: white;
    """
  end

  defp arena_style do
    """
      width: #{GameEngine.Board.width()}px;
      height: #{GameEngine.Board.height()}px;
      border: 1px solid #333;
      background: black;
      position: relative;
      //top: 150px;
      //left: 50px;
    """
  end

  defp base_player_style(%{pos: {pos_x, pos_y}, size: size, color: color}) do
    """
      //position: relative;
      position: absolute;
      top: #{pos_y - size / 2}px;
      left: #{pos_x - size / 2}px;
      width: #{size}px;
      height: #{size}px;
      border: #{size / 5}px solid #{color};
      border-radius: 50%;
      display: flex;
      align-items: center;
      color: white;
      justify-content: center;
      font-size: #{2 * (size / 3)}px;
      //-webkit-text-stroke: #{size / 50}px #f4ff77;
    """
  end


  defp player_style(%{size: size, status: :digesting, status_timer: status_timer} = player) when rem(status_timer, 2) == 0, do:
      base_player_style(player) <>
        """
          box-shadow:
          0 0 #{size / 2}px #{size / 3}px #fff,
          0 0 #{size / 1.5}px #{size / 2}px #ff0,
          0 0 #{size}px #{size}px #f0f;
        """

  defp player_style(%{status: :digesting} = player), do:
      base_player_style(player)

  defp player_style(%{status: :fleeing} = player), do:
      base_player_style(player) <> """
      border: 2px solid grey;
      """

  defp player_style(%{size: size, powered: powered} = player) when powered > 0,
    do:
      base_player_style(player) <>
        """
          box-shadow:
          0 0 #{size / 5}px #{size / 6}px #fff,
          0 0 #{size / 3}px #{size / 5}px #f0f,
          0 0 #{size / 2.15}px #{size / 3.5}px #0ff;
        """

  defp player_style(player), do: base_player_style(player)

  defp base_fruit_style({{x, y}, {size, _}}) do
    """
      //position: relative;
      position: absolute;
      top: #{y - size / 2}px;
      left: #{x - size / 2}px;
      width: #{size}px;
      height: #{size}px;
      border: 4px solid gold;
      border-radius: 50%;
    """
  end

  defp fruit_style({_, {size, :power_up}} = fruit),
    do:
      base_fruit_style(fruit) <>
        """
          box-shadow:
            inset 0 0 #{size / 6}px #fff,
            inset #{size / 15}px 0 #{size / 3.75}px #f0f,
            inset -#{size / 15}px 0 #{size / 3.75}px #0ff,
            inset #{size / 15}px 0 #{size}px #f0f,
            inset -#{size / 15}px 0 #{size}px #0ff,
            0 0 #{size / 6}px #fff,
            -#{size / 30}px 0 #{size / 3.75}px #f0f,
            #{size / 30}px 0 #{size / 3.75}px #0ff;
        """

  defp fruit_style(fruit), do: base_fruit_style(fruit)

  @impl true
  def handle_info({:board_tick, board}, socket) do
    {:noreply, assign(socket, board: board)}
  end
end
