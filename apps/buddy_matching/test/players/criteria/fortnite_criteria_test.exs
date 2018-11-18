defmodule BuddyMatching.Criteria.FortniteCriteriaTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Criteria.FortniteCriteria

  @criteria_json ~s({
    "minGamesPlayed": 5
  })

  @criteria_struct %FortniteCriteria{
    min_games_played: 5
  }

  test "entire fortniteinfo is correctly parsed from json" do
    data = Poison.Parser.parse!(@criteria_json)
    assert {:ok, @criteria_struct} == FortniteCriteria.from_json(data)
  end
end
