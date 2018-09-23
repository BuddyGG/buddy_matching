defmodule BuddyMatching.Matching.FortniteMatchingTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.FortniteInfo
  # alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.Matching.FortniteMatching, as: Matching

  test "fortnite players match when on same platform" do
    p1 = %FortniteInfo{platform: :xb1}
    p2 = %FortniteInfo{platform: :xb1}
    assert Matching.match?(p1, p2)
  end

  test "fortnite players do not match if on different platforms" do
    p1 = %FortniteInfo{platform: :ps4}
    p2 = %FortniteInfo{platform: :xb1}
    refute Matching.match?(p1, p2)
  end
end
