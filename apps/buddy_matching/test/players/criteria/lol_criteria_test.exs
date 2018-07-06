defmodule BuddyMatching.Criteria.LolCriteriaTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Criteria.LolCriteria

  @criteria ~s({
    "positions":{
        "top":true,
        "jungle":true,
        "mid":true,
        "marksman":true,
        "support":true
     }
  })

  test "entire criteria is correctly parsed from json" do
    expected_criteria = %LolCriteria{
      positions: [:jungle, :marksman, :mid, :support, :top]
    }

    data = Poison.Parser.parse!(@criteria)
    assert {:ok, expected_criteria} == LolCriteria.from_json(data)
  end

  test "too many positions is invalid" do
    data = Poison.Parser.parse!(@criteria)
    bad_data = Map.update!(data, "positions", &Map.put(&1, "AFK", true))
    assert {:error, "Too many positions in criteria"} == LolCriteria.from_json(bad_data)
  end
end
