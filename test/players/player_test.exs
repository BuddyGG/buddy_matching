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
      %Player{age_group: "20-29", champions: ["Vayne", "Caitlyn", "Ezreal"], criteria: nil, id: 1,
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
end

