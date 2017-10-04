defmodule LolBuddy.PlayerTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players.Player
  
  @player ~s({"age_group": "20-29", "champions": ["Vayne","Caitlyn","Ezreal"], "criteria": "nil", "id": "1", "languages": ["DA","EN"], "leagues": [{"type":"RANKED_SOLO_5x5","tier":"GOLD","rank":"I"}], "name": "Tester", "positions": {"top":true,"jun":true,"mid":false,"adc":false,"sup":false}, "region": "euw", "voice": true, "comment": "hello"})    
  
  test "parse from json" do
    expected_player = 
    %Player{age_group: "20-29", champions: ["Vayne", "Caitlyn", "Ezreal"], criteria: nil, id: "1", languages: ["DA", "EN"], leagues: [%{rank: "I", tier: "GOLD", type: "RANKED_SOLO_5x5"}], 
    name: "Tester", positions: ["jun","top"], region: :euw, voice: true, comment: "hello"}

    assert Player.from_json(@player) == expected_player
  end


end
