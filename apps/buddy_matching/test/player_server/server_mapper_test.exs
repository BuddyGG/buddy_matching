defmodule BuddyMatching.PlayerServer.ServerExtractorTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.PlayerServer.ServerExtractor
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.Info.LolInfo

  test "extracts region as info from lol player" do
    player = %Player{game_info: %LolInfo{region: :euw}}
    assert :euw = ServerExtractor.server_from_player(player)
  end

  test "extracts platform as server from fortnite player" do
    player = %Player{game_info: %FortniteInfo{platform: :xb1}}
    assert :xb1 = ServerExtractor.server_from_player(player)
  end
end
