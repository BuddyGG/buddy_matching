defmodule LolBuddy.MatchingTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Matching
  alias LolBuddy.Players.Criteria

  # setup some bases for criteria and players that can be used in relation
  # to custom definitions for testing
  setup_all do
    broad_criteria = %Criteria{
      positions: [:top, :jungle, :mid, :marksman, :support],
      voice: [true, false],
      age_groups: ["interval1", "interval2", "interval3"],
      ignore_language: false
    }

    narrow_criteria = %Criteria{
      positions: [:marksman],
      voice: [false],
      age_groups: ["interval1"],
      ignore_language: false
    }

    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}

    base_player1 = %Player{
      id: 1,
      name: "Lethly",
      region: :euw,
      voice: [false],
      languages: ["danish"],
      age_group: "interval1",
      positions: [:marksman],
      leagues: diamond1,
      champions: ["Vayne", "Ezreal", "Caitlyn"],
      criteria: broad_criteria,
      comment: "Never dies on Vayne"
    }

    base_player2 = %Player{
      id: 2,
      name: "hansp",
      region: :euw,
      voice: [false],
      languages: ["danish", "english"],
      age_group: "interval3",
      positions: [:top],
      leagues: diamond1,
      champions: ["Cho'Gath", "Renekton", "Riven"],
      criteria: narrow_criteria,
      comment: "Apparently I play Riven"
    }

    [
      player1: base_player1,
      broad_criteria: broad_criteria,
      diamond1: diamond1,
      player2: base_player2,
      narrow_criteria: narrow_criteria
    ]
  end

  ### --- Player matching tests --- ###
  test "players with matching criteria and valid leagues/regions are matching", context do
    assert Matching.match?(context[:player1], context[:player2])
  end

  test "players with matching criteria but no language intersection don't match", context do
    gibberishian = %Player{context[:player2] | languages: ["gibberish"]}
    refute Matching.match?(context[:player1], gibberishian)
  end

  test "player does not match himself", context do
    refute Matching.match?(context[:player1], context[:player1])
  end

  test "player with compatible criteria but bad regions are not matching", context do
    player2 = Map.put(context[:player2], :region, :br)
    refute Matching.match?(context[:player1], player2)
  end

  test "player with compatible criteria but unable to queue are not matching", context do
    diamond5 = Map.put(context[:diamond1], :rank, 5)
    player2 = Map.put(context[:player2], :leagues, diamond5)
    refute Matching.match?(context[:player1], player2)
  end

  test "player with incompatible languages match if they ignore languages", context do
    ignore_lang = %Criteria{context[:broad_criteria] | ignore_language: true}
    swe_player = %Player{context[:player1] | languages: ["swe"], criteria: ignore_lang}
    dk_player = %Player{context[:player2] | languages: ["dk"], criteria: ignore_lang}
    assert Matching.match?(swe_player, dk_player)
  end

  test "player with incompatible languages match don't match if they don't ignore languages",
       context do
    ignore_lang = %Criteria{context[:broad_criteria] | ignore_language: false}
    swe_player = %Player{context[:player1] | languages: ["swe"], criteria: ignore_lang}
    dk_player = %Player{context[:player2] | languages: ["dk"], criteria: ignore_lang}
    refute Matching.match?(swe_player, dk_player)
  end

  test "player with compatible languages match still match if they ignore_language", context do
    ignore_lang = %Criteria{context[:broad_criteria] | ignore_language: true}
    swe_player = %Player{context[:player1] | languages: ["dk"], criteria: ignore_lang}
    dk_player = %Player{context[:player2] | languages: ["dk"], criteria: ignore_lang}
    assert Matching.match?(swe_player, dk_player)
  end

  test "player with compatible languages match still match if they don't ignore_language",
       context do
    ignore_lang = %Criteria{context[:broad_criteria] | ignore_language: false}
    swe_player = %Player{context[:player1] | languages: ["dk"], criteria: ignore_lang}
    dk_player = %Player{context[:player2] | languages: ["dk"], criteria: ignore_lang}
    assert Matching.match?(swe_player, dk_player)
  end

  ### --- Criteria compatibility tests --- ###
  test "test that 1:1 criteria/player fit is compatible", context do
    perfect_criteria = %Criteria{
      positions: [:marksman],
      voice: [false],
      age_groups: ["interval1"]
    }

    assert Matching.criteria_compatible?(perfect_criteria, context[:player1])
  end

  test "test that voice criteria, for no voice player is incompatible", context do
    voice_criteria = %Criteria{positions: [:marksman], voice: [true], age_groups: ["interval1"]}
    refute Matching.criteria_compatible?(voice_criteria, context[:player1])
  end

  test "test that don't care voice option, matches both false and true voice criteria", context do
    dont_care_player = %Player{context[:player1] | voice: [true, false]}
    voice_criteria = %Criteria{positions: [:marksman], voice: [true], age_groups: ["interval1"]}

    no_voice_criteria = %Criteria{
      positions: [:marksman],
      voice: [false],
      age_groups: ["interval1"]
    }

    assert Matching.criteria_compatible?(voice_criteria, dont_care_player)
    assert Matching.criteria_compatible?(no_voice_criteria, dont_care_player)
  end

  test "test that age_group criteria doesn't match with bad age groups for player", context do
    age_criteria = %Criteria{
      positions: [:marksman],
      voice: [true],
      age_groups: ["interval2", "interval3"]
    }

    refute Matching.criteria_compatible?(age_criteria, context[:player1])
  end

  test "test that positions criteria doesn't match with other positions", context do
    positions_criteria = %Criteria{
      positions: [:jungle, :mid, :support, :top],
      voice: [true, false],
      age_groups: ["interval1", "interval2", "interval3"]
    }

    refute Matching.criteria_compatible?(positions_criteria, context[:player1])
  end

  test "test that compatible positions criteria matches", context do
    positions_criteria = %Criteria{
      positions: [:jungle, :mid, :support, :top, :marksman],
      voice: [true, false],
      age_groups: ["interval1", "interval2", "interval3"]
    }

    assert Matching.criteria_compatible?(positions_criteria, context[:player1])
  end

  test "test that entirely wrong criteria/player combination is incompatible", context do
    bad_criteria = %Criteria{positions: [:support], voice: [true], age_groups: ["interval3"]}
    refute Matching.criteria_compatible?(bad_criteria, context[:player1])
  end

  ### --- Sort leagues tests --- ###
  test "diamond is higher than platinum", context do
    platinum = Map.put(context[:diamond1], :tier, "PLATINUM")
    {high, low} = Matching.sort_leagues(platinum, context[:diamond1])
    assert low == platinum
    assert high == context[:diamond1]
  end

  test "diamond1 is higher than diamond2", context do
    diamond2 = Map.put(context[:diamond1], :rank, 2)
    {high, low} = Matching.sort_leagues(diamond2, context[:diamond1])
    assert low == diamond2
    assert high == context[:diamond1]
  end

  test "master is higher than diamond1", context do
    master = Map.put(context[:diamond1], :tier, "MASTER")
    {high, low} = Matching.sort_leagues(master, context[:diamond1])
    assert low == context[:diamond1]
    assert high == master
  end

  ### --- Tier compatibility tests --- ###
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

  test "plat and unranked are compatible" do
    platinum1 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 1}
    unranked = %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: 5}
    refute Matching.tier_compatible?(platinum1, unranked)
  end

  test "unranked is compatible with bronze, silver and gold" do
    bronze = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 1}
    silver = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 1}
    gold = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
    unranked = %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: 5}
    assert Matching.tier_compatible?(unranked, bronze)
    assert Matching.tier_compatible?(unranked, silver)
    assert Matching.tier_compatible?(unranked, gold)
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

  test "gold with no rank is compatible with plat/gold/silver" do
    platinum1 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 1}
    silver5 = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 5}
    gold3 = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 3}
    gold = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: nil}
    assert Matching.tier_compatible?(gold, platinum1)
    assert Matching.tier_compatible?(gold, gold3)
    assert Matching.tier_compatible?(gold, silver5)
  end

  test "diamond with no rank is compatible with diamond/plat" do
    diamond = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: nil}
    platinum1 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 1}
    assert Matching.tier_compatible?(diamond, platinum1)
  end

  test "diamond1 can't queue with diamond with no rank" do
    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
    diamond = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: nil}
    refute Matching.tier_compatible?(diamond, diamond1)
  end
end
