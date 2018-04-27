defmodule BuddyMatching.Matching.FortniteMatchingTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.FortniteInfo
  # alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.Matching.FortniteMatching, as: Matching

  test "fortnite matching test" do
    p1 = %FortniteInfo{platform: :xb1}
    p2 = %FortniteInfo{platform: :xb1}
    assert Matching.match?(p1, p2)
  end
end
