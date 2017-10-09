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
          "rank":"I"
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
          "DA"
       ],
       "voicechat":true,
       "agegroup":"20-29",
       "comment":"test"
    }
 })

  test "parse from json" do
    expected_player = 
    %Player{age_group: "20-29", champions: ["Vayne", "Caitlyn", "Ezreal"], criteria: nil, id: 1, languages: ["DA"], leagues: [%{rank: "I", tier: "GOLD", type: "RANKED_SOLO_5x5"}], 
    name: "Lethly", positions: [:top, :jungle], region: :euw, voice: true, comment: "test"}
    data = Poison.Parser.parse!(@player)
    assert Player.from_json(data) == expected_player
  end


end
