defmodule BuddyMatching.StatsControllerTest do
  use BuddyMatchingWeb.ConnCase
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatching.Players.Player

  test "1 connected player to a euw server returns 1 player" do
    player = %Player{id: "1", name: "foo", server: :euw}
    ServerMapper.add_player(player)

    conn = build_conn()

    players_online =
      conn
      |> get(stats_path(conn, :show))
      |> json_response(200)
      |> Map.get("players_online")

    # players should leave again to leave no trace
    ServerMapper.remove_player(player)

    assert players_online["euw"] == 1

    # all other servers should be 0
    players_online
    |> Map.delete("euw")
    |> Enum.all?(fn {_server, count} -> count == 0 end)
    |> assert
  end

  test "1 connected player to a br server returns 1 player" do
    player = %Player{id: "1", name: "foo", server: :br}
    ServerMapper.add_player(player)

    conn = build_conn()

    players_online =
      conn
      |> get(stats_path(conn, :show))
      |> json_response(200)
      |> Map.get("players_online")

    # players should leave agin to leave no trace
    ServerMapper.remove_player(player)

    assert players_online["br"] == 1

    # all other servers should be 0
    players_online
    |> Map.delete("br")
    |> Enum.all?(fn {_server, count} -> count == 0 end)
    |> assert
  end
end
