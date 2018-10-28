defmodule BuddyMatching.StatsControllerTest do
  use BuddyMatchingWeb.ConnCase
  alias BuddyMatching.PlayerServer.ServerMapper
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo

  test "1 connected player to a euw server returns 1 player" do
    info = %LolInfo{region: :euw}
    player = %Player{id: "1", name: "foo", game_info: info}
    ServerMapper.add_player(player)

    conn = build_conn()

    players_online =
      conn
      |> get(stats_path(conn, :show_server, "lol", "euw"))
      |> json_response(200)
      |> Map.get("players_online")

    assert players_online == 1

    # players should leave again to leave no trace
    ServerMapper.remove_player(player)

    players_online =
      conn
      |> get(stats_path(conn, :show_server, "lol", "euw"))
      |> json_response(200)
      |> Map.get("players_online")

    assert players_online == 0
  end

  test "players online works across multiple games" do
    lol_info = %LolInfo{region: :euw}
    lol_player = %Player{id: "1", name: "foo", game_info: lol_info}

    fortnite_info = %FortniteInfo{platform: :pc}
    fortnite_player = %Player{id: "2", name: "bar", game_info: fortnite_info}
    ServerMapper.add_player(lol_player)
    ServerMapper.add_player(fortnite_player)

    conn = build_conn()

    players_online =
      conn
      |> get(stats_path(conn, :show))
      |> json_response(200)
      |> Map.get("players_online")

    assert players_online["lol"]["euw"] == 1
    assert players_online["fortnite"]["pc"] == 1
  end
end
