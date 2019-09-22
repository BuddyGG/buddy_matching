defmodule BuddyMatching.PlayerTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.Criteria.PlayerCriteria

  @player_json ~s({
    "name": "Lethly",
    "id": 1,
    "game": "lol",
    "voiceChat": true,
    "ageGroup": "interval2",
    "comment": "test",
    "languages": [
      "DA",
      "KO",
      "EN"
    ],
    "criteria": {
      "ageGroups": {
        "interval1": true,
        "interval2": true,
        "interval3": true
      },
      "voiceChat": {
        "YES": true,
        "NO": true
      },
      "ignoreLanguage": false
    },
    "gameInfo": {
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
          "mid": false,
          "marksman": false,
          "support": false
        }
      }
    }
  })

  @player_struct %Player{
    name: "Lethly",
    id: 1,
    game: :lol,
    age_group: "interval2",
    comment: "test",
    languages: ["EN", "DA", "KO"],
    voice: true,
    criteria: %PlayerCriteria{
      age_groups: ["interval1", "interval2", "interval3"],
      voice: [false, true],
      ignore_language: false
    },
    game_info: %LolInfo{
      icon_id: 512,
      region: :euw,
      game_criteria: %LolCriteria{
        positions: [:jungle, :top]
      },
      leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
      positions: [:jungle, :top],
      champions: ["Vayne", "Caitlyn", "Ezreal"]
    }
  }

  test "entire player is correctly parsed from json" do
    data = Poison.Parser.parse!(@player_json)
    assert {:ok, @player_struct} == Player.from_json(data)
  end

  test "from json returns error when json is invalid" do
    data = Poison.Parser.parse!(@player_json)
    long_name = String.duplicate("a", 17)
    bad_data = Map.put(data, "name", long_name)
    assert {:error, "Name too long"} == Player.from_json(bad_data)
  end

  test "test that languages are correctly parsed and sorted with english" do
    input = ["DK", "KR", "EN", "FR"]
    expected_languages = ["EN", "DK", "FR", "KR"]
    assert expected_languages == Player.languages_from_json(input)
  end

  test "test that languages are correctly parsed and sorted without english" do
    input = ["DK", "KR", "GR", "FR"]
    expected_languages = ["DK", "FR", "GR", "KR"]
    assert expected_languages == Player.languages_from_json(input)
  end

  test "too long comment in player json is invalid" do
    data = Poison.Parser.parse!(@player_json)
    long_comment = String.duplicate("a", 101)
    bad_data = Map.put(data, "comment", long_comment)

    assert {:error, "Comment too long"} == Player.from_json(bad_data)
  end

  test "comment can be nil" do
    data = Poison.Parser.parse!(@player_json)
    data = Map.put(data, "comment", nil)
    expected_player = Map.put(@player_struct, :comment, nil)

    assert {:ok, expected_player} == Player.from_json(data)
  end

  test "too many selected languages is invalid" do
    data = Poison.Parser.parse!(@player_json)
    too_many_languages = ["DK", "ENG", "SWE", "NO", "BR", "SP"]
    bad_data = Map.put(data, "languages", too_many_languages)

    assert {:error, "Too many langauges"} == Player.from_json(bad_data)
  end

  test "too long player name is invalid" do
    data = Poison.Parser.parse!(@player_json)
    long_name = String.duplicate("a", 17)
    bad_data = Map.put(data, "name", long_name)
    assert {:error, "Name too long"} == Player.from_json(bad_data)
  end
end
