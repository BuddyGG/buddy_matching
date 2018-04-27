defmodule BuddyMatching.Matching.PlayerMatchingTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Matching.PlayerMatching, as: Matching
  alias BuddyMatching.Players.Criteria.PlayerCriteria, as: Criteria

  # setup some bases for criteria and players that can be used in relation
  # to custom definitions for testing
  setup_all do
    broad_criteria = %Criteria{
      voice: [true, false],
      age_groups: ["interval1", "interval2", "interval3"],
      ignore_language: false
    }

    narrow_criteria = %Criteria{
      voice: [false],
      age_groups: ["interval1"],
      ignore_language: false
    }

    base_player1 = %Player{
      id: 1,
      name: "Lethly",
      voice: [false],
      languages: ["danish"],
      age_group: "interval1",
      criteria: broad_criteria,
      comment: "Never dies on Vayne"
    }

    base_player2 = %Player{
      id: 2,
      name: "hansp",
      voice: [false],
      languages: ["danish", "english"],
      age_group: "interval3",
      criteria: narrow_criteria,
      comment: "Apparently I play Riven"
    }

    [
      player1: base_player1,
      player2: base_player2,
      broad_criteria: broad_criteria,
      narrow_criteria: narrow_criteria
    ]
  end

  ### --- Player matching tests --- ###
  test "players with matching criteria and valid leagues/servers are matching", context do
    assert Matching.match?(context[:player1], context[:player2])
  end

  test "players with matching criteria but no language intersection don't match", context do
    gibberishian = %Player{context[:player2] | languages: ["gibberish"]}
    refute Matching.match?(context[:player1], gibberishian)
  end

  test "player does not match himself", context do
    refute Matching.match?(context[:player1], context[:player1])
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
      voice: [false],
      age_groups: ["interval1"]
    }

    assert Matching.criteria_compatible?(perfect_criteria, context[:player1])
  end

  test "test that voice criteria, for no voice player is incompatible", context do
    voice_criteria = %Criteria{voice: [true], age_groups: ["interval1"]}
    refute Matching.criteria_compatible?(voice_criteria, context[:player1])
  end

  test "test that don't care voice option, matches both false and true voice criteria", context do
    dont_care_player = %Player{context[:player1] | voice: [true, false]}
    voice_criteria = %Criteria{voice: [true], age_groups: ["interval1"]}

    no_voice_criteria = %Criteria{
      voice: [false],
      age_groups: ["interval1"]
    }

    assert Matching.criteria_compatible?(voice_criteria, dont_care_player)
    assert Matching.criteria_compatible?(no_voice_criteria, dont_care_player)
  end

  test "test that age_group criteria doesn't match with bad age groups for player", context do
    age_criteria = %Criteria{
      voice: [true],
      age_groups: ["interval2", "interval3"]
    }

    refute Matching.criteria_compatible?(age_criteria, context[:player1])
  end

  test "test that entirely wrong criteria/player combination is incompatible", context do
    bad_criteria = %Criteria{voice: [true], age_groups: ["interval3"]}
    refute Matching.criteria_compatible?(bad_criteria, context[:player1])
  end
end
