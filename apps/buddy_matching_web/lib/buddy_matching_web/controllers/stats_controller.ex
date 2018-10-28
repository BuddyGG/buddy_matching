defmodule BuddyMatchingWeb.StatsController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  alias BuddyMatching.PlayerServer.ServerMapper

  @doc """
  Get request to get the amount of currently connected players
  for all servers under all games.
  """
  def show(conn, _param) do
    stats = ServerMapper.count_all_players()
    render(conn, "show.json", stats: stats)
  end

  @doc """
  Get request to get the amount of currently connected players
  for a specific server.
  """
  def show_server(conn, %{"game" => _game, "server" => server}) do
    server_atom = String.to_existing_atom(server)
    stats = ServerMapper.count_players(server_atom)
    render(conn, "show_server.json", stats: stats)
  end
end
