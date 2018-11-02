defmodule BuddyMatching.Matching.FortniteMatchingTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.Matching.FortniteMatching, as: Matching

  @criteria10 %FortniteCriteria{min_games_played: 10}
  @criteria5 %FortniteCriteria{min_games_played: 5}

  test "fortnite players match matches based on platform" do
    p1 = %FortniteInfo{platform: :xb1, games_played: 11, game_criteria: @criteria10}
    p2 = %FortniteInfo{platform: :xb1, games_played: 12, game_criteria: @criteria10}
    p3 = %FortniteInfo{platform: :ps4, games_played: 13, game_criteria: @criteria10}
    assert Matching.match?(p1, p2)
    refute Matching.match?(p2, p3)
    refute Matching.match?(p1, p3)
  end

  test "fortnite players match based on games_played" do
    p1 = %FortniteInfo{platform: :ps4, games_played: 13, game_criteria: @criteria10}
    p2 = %FortniteInfo{platform: :ps4, games_played: 9, game_criteria: @criteria10}
    p3 = %FortniteInfo{platform: :ps4, games_played: 11, game_criteria: @criteria5}
    refute Matching.match?(p1, p2)
    assert Matching.match?(p2, p3)
    assert Matching.match?(p1, p3)
  end
end
