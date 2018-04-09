defmodule BuddyMatching.PlayerTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Player

  @player ~s({
    "champions":[
       "Vayne",
       "Caitlyn",
       "Ezreal"
    ],
    "icon_id":512,
    "leagues":{
          "type":"RANKED_SOLO_5x5",
          "tier":"GOLD",
          "rank":1
     },
    "positions":[
       "marksman"
    ],
    "name":"Lethly",
    "region":"euw",
    "userInfo":{
      "criteria": {
        "positions":{
            "top":true,
            "jungle":true,
            "mid":true,
            "marksman":true,
            "support":true
         },
         "ageGroups":{
            "interval1":true,
            "interval2":true,
            "interval3":true
         },
         "voiceChat":{
            "YES":true,
            "NO":true
         },
         "ignoreLanguage": false
      },
      "id" : 1,
       "selectedRoles":{
          "top":true,
          "jungle":true,
          "mid":false,
          "marksman":false,
          "support":false
       },
       "languages":[
          "DA",
          "KO",
          "EN"

       ],
       "voicechat":[true],
       "agegroup":"interval2",
       "comment":"test"
    }
 })

  test "entire player is correctly parsed from json" do
    expected_player =
      {:ok,
       %Player{
         age_group: "interval2",
         champions: ["Vayne", "Caitlyn", "Ezreal"],
         criteria: %BuddyMatching.Players.Criteria{
           age_groups: ["interval1", "interval2", "interval3"],
           positions: [:jungle, :marksman, :mid, :support, :top],
           voice: [false, true],
           ignore_language: false
         },
         id: 1,
         languages: ["EN", "DA", "KO"],
         leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
         name: "Lethly",
         positions: [:jungle, :top],
         region: :euw,
         voice: [true],
         comment: "test"
       }}

    data = Poison.Parser.parse!(@player)
    assert Player.from_json(data) == expected_player
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
    assert expected_positions == Player.positions_from_json(input)
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

  test "valid player json validates to true" do
    data = Poison.Parser.parse!(@player)
    assert Player.validate_player_json(data)
  end

  test "too long comment in player json is invalid" do
    data = Poison.Parser.parse!(@player)
    long_comment = String.duplicate("a", 101)

    bad_user_info =
      data["userInfo"]
      |> Map.put("comment", long_comment)

    bad_data = Map.put(data, "userInfo", bad_user_info)
    assert Player.validate_player_json(bad_data) == {:error, "Comment too long"}
  end

  test "comment can be nil" do
    data = Poison.Parser.parse!(@player)
    no_comment = nil

    bad_user_info =
      data["userInfo"]
      |> Map.put("comment", no_comment)

    bad_data = Map.put(data, "userInfo", bad_user_info)
    assert Player.validate_player_json(bad_data)
  end

  test "too many selected roles is invalid" do
    data = Poison.Parser.parse!(@player)

    bad_user_info =
      data["userInfo"]
      |> Map.update!("selectedRoles", &Map.put(&1, "a", "b"))

    bad_data = Map.put(data, "userInfo", bad_user_info)
    assert Player.validate_player_json(bad_data) == {:error, "Too many roles selected"}
  end

  test "too many selected languages is invalid" do
    data = Poison.Parser.parse!(@player)

    too_many_languages = ["DK", "ENG", "SWE", "NO", "BR", "SP"]

    bad_user_info =
      data["userInfo"]
      |> Map.put("languages", too_many_languages)

    bad_data = Map.put(data, "userInfo", bad_user_info)
    assert Player.validate_player_json(bad_data) == {:error, "Too many langauges"}
  end

  test "too long player name is invalid" do
    data = Poison.Parser.parse!(@player)
    long_name = String.duplicate("a", 17)
    bad_data = Map.put(data, "name", long_name)
    assert Player.validate_player_json(bad_data) == {:error, "Name too long"}
  end

  test "player with null rank is valid json" do
    player = String.replace(@player, "\"rank\":1", "\"rank\":null")
    data = Poison.Parser.parse!(player)
    assert Player.validate_player_json(data)
  end

  test "player with null rank is parsed correctly" do
    expected_player =
      {:ok,
       %Player{
         age_group: "interval2",
         champions: ["Vayne", "Caitlyn", "Ezreal"],
         criteria: %BuddyMatching.Players.Criteria{
           age_groups: ["interval1", "interval2", "interval3"],
           positions: [:jungle, :marksman, :mid, :support, :top],
           voice: [false, true]
         },
         id: 1,
         languages: ["EN", "DA", "KO"],
         leagues: %{rank: nil, tier: "GOLD", type: "RANKED_SOLO_5x5"},
         name: "Lethly",
         positions: [:jungle, :top],
         region: :euw,
         voice: [true],
         comment: "test"
       }}

    player = String.replace(@player, "\"rank\":1", "\"rank\":null")
    data = Poison.Parser.parse!(player)
    assert expected_player == Player.from_json(data)
  end
end
