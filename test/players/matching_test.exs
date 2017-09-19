defmodule LolBuddy.MatchingTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Player
  alias LolBuddy.Players.Matching
  alias LolBuddy.Players.Criteria

  # setup some bases for criteria and players that can be used in relation
  # to custom definitions for testing
  setup_all do
    broad_criteria = %Criteria{positions: [:top, :jungle, :mid, :marksman, :support],
      voice: false, age_groups: [1,2,3]}

    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}

    base_player1 = %Player{id: 1, name: "Lethly", region: :euw, voice: false,
      languages: ["danish"], age_group: 1, positions: [:marksman],
      league: [diamond1], criteria: broad_criteria}

    [player1: base_player1, broad_criteria: broad_criteria, diamond1: diamond1]
  end

  @tag :pending
  test "same league different positions and matching criteria", context do
    player2 = %{context[:player1] | id: 2, name: "hansp", positions: [:top]}
    assert Matching.match?(context[:player1], player2)
  end

  test "diamond is higher than platinum", context do
    platinum = Map.put(context[:diamond1], :tier, "PLATINUM")
    {high, low} = Matching.sort_league(platinum, context[:diamond1])
    assert low == platinum
    assert high == context[:diamond1]
  end

  test "diamond1 is higher than diamond2", context do
    diamond2 = Map.put(context[:diamond1], :rank, 2)
    {high, low} = Matching.sort_league(diamond2, context[:diamond1])
    assert low == diamond2
    assert high == context[:diamond1]
  end

  test "master is higher than diamond1", context do
    master = Map.put(context[:diamond1], :tier, "MASTER")
    {high, low} = Matching.sort_league(master, context[:diamond1])
    assert low == context[:diamond1]
    assert high == master
  end

  test "silver and bronze are tier compatible" do
    silver = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 1}
    bronze = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 5}
    assert Matching.tier_compatible?(silver, bronze)
  end

  test "silver and gold are compatible" do
    silver = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 5}
    gold = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
    assert Matching.tier_compatible?(silver, gold)
  end

  test "bronze and gold are incompatible" do
    bronze = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 1}
    gold = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 5}
    refute Matching.tier_compatible?(bronze, gold)
  end

  test "plat1 and gold5 are compatible" do
    platinum1 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 1}
    gold5 = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 5}
    assert Matching.tier_compatible?(platinum1, gold5)
  end

  test "diamond5 and plat3 are compatible" do
    platinum3 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 3}
    diamond5 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 5}
    assert Matching.tier_compatible?(platinum3, diamond5)
  end

  test "diamond4 and plat3 are incompatible" do
    platinum3 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 3}
    diamond4 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 4}
    refute Matching.tier_compatible?(platinum3, diamond4)
  end

  test "diamond1 and diamond5 are incompatible" do
    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
    diamond5 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 5}
    refute Matching.tier_compatible?(diamond1, diamond5)
  end

  test "master and diamond3 are compatible" do
    master = %{type: "RANKED_SOLO_5x5", tier: "MASTER", rank: 1}
    diamond3 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 3}
    assert Matching.tier_compatible?(master, diamond3)
  end

  test "master and diamond4 are incompatible" do
    master = %{type: "RANKED_SOLO_5x5", tier: "MASTER", rank: 1}
    diamond4 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 4}
    refute Matching.tier_compatible?(master, diamond4)
  end

  test "challenger is always incompatible" do
    challenger = %{type: "RANKED_SOLO_5x5", tier: "CHALLENGER", rank: 1}
    refute Matching.tier_compatible?(challenger, challenger)
  end
end
