defmodule BuddyMatching.Info.FortniteInfoTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.Criteria.FortniteCriteria

  @info_json ~s({
    "platform": "pc",
    "gamesPlayed": 1
  })

  @info_json_full ~s({
    "platform": "pc",
    "gamesPlayed": 1,
    "solo": {
      "gamesPlayed": 5039,
      "gamesWon": 1774,
      "killDeathRatio": 11.503828483920367,
      "top10finishes": 2387,
      "top25finishes": 2859
    },
    "duo": {
      "gamesPlayed": 3994,
      "gamesWon": 1648,
      "killDeathRatio": 11.935635123614663,
      "top12finishes": 2390,
      "top5finishes": 2018
    },
    "squad": {
      "gamesPlayed": 3838,
      "gamesWon": 1327,
      "killDeathRatio": 10.087216248506572,
      "top3finishes": 1595,
      "top6finishes": 1873},
    "total": {
      "totalGamesPlayed": 10360,
      "totalGamesWon": 4749
    },
    "gameCriteria": {
      "minGamesPlayed": 1
    }
  })

  @info_struct %FortniteInfo{
    platform: :pc,
    games_played: 1,
    solo: %{
      "gamesPlayed" => 5039,
      "gamesWon" => 1774,
      "killDeathRatio" => 11.503828483920367,
      "top10finishes" => 2387,
      "top25finishes" => 2859
    },
    duo: %{
      "gamesPlayed" => 3994,
      "gamesWon" => 1648,
      "killDeathRatio" => 11.935635123614663,
      "top12finishes" => 2390,
      "top5finishes" => 2018
    },
    squad: %{
      "gamesPlayed" => 3838,
      "gamesWon" => 1327,
      "killDeathRatio" => 10.087216248506572,
      "top3finishes" => 1595,
      "top6finishes" => 1873
    },
    total: %{"totalGamesPlayed" => 10_360, "totalGamesWon" => 4749}
  }

  @info_struct_full %FortniteInfo{
    @info_struct
    | game_criteria: %FortniteCriteria{min_games_played: 1}
  }
  test "fortnite_info_from_json parses info correctly from json" do
    data = Poison.Parser.parse!(@info_json_full)
    assert {:ok, @info_struct} == FortniteInfo.fortnite_info_from_json(data)
  end

  test "parsing fortniteinfo with invalid platform returns an error" do
    data = Poison.Parser.parse!(@info_json)
    invalid_data = put_in(data["platform"], "gibberish")

    assert {:error, "Platform should be one of [\"pc\", \"ps4\", \"xbox\"]"} ==
             FortniteInfo.from_json(invalid_data)
  end

  test "from_json/1 parses fortniteinfo and the underlying criteria" do
    data = Poison.Parser.parse!(@info_json_full)
    assert {:ok, @info_struct_full} == FortniteInfo.from_json(data)
  end
end
