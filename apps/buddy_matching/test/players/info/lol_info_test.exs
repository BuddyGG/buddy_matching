defmodule BuddyMatching.Info.LolInfoTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Criteria.LolCriteria

  @info_json ~s({
    "iconId": 512,
    "region": "euw",
    "champions": [
      "Vayne",
      "Caitlyn",
      "Ezreal"
    ],
    "leagues": {
      "type": "RANKED_SOLO_5x5",
      "tier": "GOLD",
      "rank": 1
    },
    "selectedRoles": {
      "top": true,
      "jungle": true,
      "mid": false,
      "marksman": false,
      "support": false
    },
    "gameCriteria": {
      "positions": {
        "top": true,
        "jungle": true,
        "mid": true,
        "marksman": true,
        "support": true
      }
    }
})

  @info_struct %LolInfo{
    icon_id: 512,
    region: :euw,
    game_criteria: %LolCriteria{
      positions: [:jungle, :marksman, :mid, :support, :top]
    },
    leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
    positions: [:jungle, :top],
    champions: ["Vayne", "Caitlyn", "Ezreal"]
  }

  test "entire lolinfo is correctly parsed from json" do
    data = Poison.Parser.parse!(@info_json)
    assert {:ok, @info_struct} == LolInfo.from_json(data)
  end

  test "test two positions are correctly parsed from json" do
    input = %{
      "jungle" => true,
      "marksman" => false,
      "mid" => true,
      "support" => false,
      "top" => false
    }

    expected_positions = [:jungle, :mid]
    assert expected_positions == LolInfo.positions_from_json(input)
  end

  test "too many selected roles is invalid" do
    data = Poison.Parser.parse!(@info_json)
    bad_info = Kernel.put_in(data["selectedRoles"]["a"], "b")
    assert {:error, "Too many roles selected"} == LolInfo.from_json(bad_info)
  end

  test "lolinfo with null rank is valid json" do
    info = String.replace(@info_json, "\"rank\": 1", "\"rank\": null")
    data = Poison.Parser.parse!(info)
    expected_info = Kernel.put_in(@info_struct.leagues.rank, nil)
    assert {:ok, expected_info} == LolInfo.from_json(data)
  end
end
