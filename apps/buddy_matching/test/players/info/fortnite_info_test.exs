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
    "gameCriteria": {
      "minGamesPlayed": 1
    }
  })

  @info_struct %FortniteInfo{
    platform: :pc,
    games_played: 1
  }

  @info_struct_full %FortniteInfo{
    @info_struct
    | game_criteria: %FortniteCriteria{min_games_played: 1}
  }
  test "fortnite_info_from_json parses info correctly from json" do
    data = Poison.Parser.parse!(@info_json)
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
