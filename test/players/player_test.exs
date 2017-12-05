defmodule LolBuddy.PlayerTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players.Player
  
  @player ~s({
    "champions":[
       "Vayne",
       "Caitlyn",
       "Ezreal"
    ],
    "icon_id":512,
    "leagues":[
       {
          "type":"RANKED_SOLO_5x5",
          "tier":"GOLD",
          "rank":1
       }
    ],
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
         }
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
       "voicechat":true,
       "agegroup":"20-29",
       "comment":"test"
    }
 })

  test "entire player is correctly parsed from json" do
    expected_player = 
      %Player{
        age_group: "20-29", champions: ["Vayne", "Caitlyn", "Ezreal"], 
        criteria: %LolBuddy.Players.Criteria{
          age_groups: ["interval1", "interval2", "interval3"], 
          positions: [:jungle, :marksman, :mid, :support, :top], 
          voice: [false, true]
        }, 
        id: 1,
        languages: ["EN", "DA", "KO"], leagues: [%{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"}], 
        name: "Lethly", positions: [:jungle, :top], region: :euw, voice: true, comment: "test"}
    data = Poison.Parser.parse!(@player)
    assert Player.from_json(data) == expected_player
  end

  test "test two positions are correctly parsed from json" do
    input = %{"jungle" => true, "marksman" => false, "mid" => true, "support" => false, "top" => false}
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
end
