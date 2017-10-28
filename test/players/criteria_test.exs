defmodule LolBuddy.CriteriaTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players.Criteria
  
  @criteria ~s({
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
  })

  test "entire criteria is correctly parsed from json" do
    expected_criteria = 
      %Criteria{positions: [:jungle, :marksman, :mid, :support, :top], 
        age_groups: ["interval1", "interval2", "interval3"],
        voice: [false, true]}
    data = Poison.Parser.parse!(@criteria)
    assert Criteria.from_json(data) == expected_criteria
  end

  @tag :pending
  test "test two positions are correctly parsed from json" do
    input = %{"jungle" => true, "marksman" => false, "mid" => true, "support" => false, "top" => false}
    expected_positions = [:jungle, :mid]
    assert expected_positions == Player.positions_from_json(input)
  end
end
