defmodule BuddyMatching.Matching.FortniteMatchingTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Matching.FortniteMatching, as: Matching

  test "fortnite matching test" do
    p1 = %Player{name: "1", id: "1", server: :xb1}
    p2 = %Player{name: "2", id: "2", server: :xb1}
    assert Matching.match?(p1, p2)
  end
end
