defmodule LolBuddy.PlayersTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria

  # The intrinsics of matchings are covered in matching specific tests,
  # as such these tests are aimed at tests on lists of players through the
  # Players module.
  setup_all do
    broad_criteria = %Criteria{
      positions: [:top, :jungle, :mid, :marksman, :support],
      voice: [false],
      age_groups: [1, 2, 3]
    }

    master = %{type: "RANKED_SOLO_5x5", tier: "MASTER", rank: 1}
    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
    platinum2 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 2}
    gold3 = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 3}
    silver4 = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 4}
    bronze5 = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 5}
    unranked = %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: 4}

    base_player1 = %Player{
      id: 1,
      name: "Froggen",
      region: :euw,
      voice: false,
      languages: ["danish"],
      age_group: 1,
      positions: [:mid],
      leagues: master,
      champions: ["LeBlanc", "Syndra", "Fizz"],
      criteria: broad_criteria,
      comment: "Haha DDOS Frogger"
    }

    base_player2 = %Player{
      id: 2,
      name: "Lethly",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:marksman],
      leagues: diamond1,
      champions: ["Vayne", "Ezreal", "Caitlyn"],
      criteria: broad_criteria,
      comment: "Never dies on Vayne"
    }

    base_player3 = %Player{
      id: 3,
      name: "hansp",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:top],
      leagues: platinum2,
      champions: ["Cho'Gath", "Renekton", "Riven"],
      criteria: broad_criteria,
      comment: "Apparently plays Riven"
    }

    base_player4 = %Player{
      id: 4,
      name: "esow",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:jungle],
      leagues: gold3,
      champions: ["Lee'Sin", "Ekko", "Vayne"],
      criteria: broad_criteria,
      comment: "Lul, I'm only Platinum 4"
    }

    base_player5 = %Player{
      id: 5,
      name: "UghUgh",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:support],
      leagues: silver4,
      champions: ["Braum", "Leona", "Blitzcrank"],
      criteria: broad_criteria,
      comment: "That's okay guys, I'll hit the next one"
    }

    base_player6 = %Player{
      id: 6,
      name: "xm3m3l0rd69x",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:mid, :marksman],
      leagues: bronze5,
      champions: ["Yasuo", "Riven", "Vayne"],
      criteria: broad_criteria,
      comment: "Am in elo hell, but am good"
    }

    base_player7 = %Player{
      id: 7,
      name: "LordOfDeathIThink",
      region: :euw,
      voice: false,
      languages: ["danish", "english"],
      age_group: 1,
      positions: [:jungle],
      leagues: unranked,
      champions: ["Yasuo", "Riven", "Vayne"],
      criteria: broad_criteria,
      comment: "I don't play very much"
    }

    all_players = [
      base_player1,
      base_player2,
      base_player3,
      base_player4,
      base_player5,
      base_player6,
      base_player7
    ]

    [
      master_player: base_player1,
      d1_player: base_player2,
      p2_player: base_player3,
      g3_player: base_player4,
      s4_player: base_player5,
      b5_player: base_player6,
      unranked_player: base_player7,
      all_players: all_players
    ]
  end

  test "two players match", %{p2_player: player1, g3_player: player2} do
    other_players = [player2]

    # other_players should all be matching with player1
    assert ^other_players = Players.get_matches(player1, other_players)
  end

  test "master player matches only d1 from players", context do
    matches = Players.get_matches(context[:master_player], context[:all_players])
    assert length(matches) == 1
    assert Enum.member?(matches, context[:d1_player])
  end

  test "gold matches both plat, silver and unranked", context do
    matches = Players.get_matches(context[:g3_player], context[:all_players])
    assert length(matches) == 3
    assert Enum.member?(matches, context[:s4_player])
    assert Enum.member?(matches, context[:unranked_player])
    assert Enum.member?(matches, context[:p2_player])
  end

  test "silver matches both gold, bronze and unranked", context do
    matches = Players.get_matches(context[:s4_player], context[:all_players])
    assert length(matches) == 3
    assert Enum.member?(matches, context[:g3_player])
    assert Enum.member?(matches, context[:b5_player])
    assert Enum.member?(matches, context[:unranked_player])
  end

  test "unranked matches both gold, silver and bronze", context do
    matches = Players.get_matches(context[:unranked_player], context[:all_players])
    assert length(matches) == 3
    assert Enum.member?(matches, context[:g3_player])
    assert Enum.member?(matches, context[:s4_player])
    assert Enum.member?(matches, context[:b5_player])
  end

  test "players with incompatible position/position criteria don't match", context do
    narrow_criteria = %Criteria{positions: [:support], voice: [true], age_groups: [3]}
    narrow_s4 = %Player{context[:s4_player] | criteria: narrow_criteria}
    matches = Players.get_matches(narrow_s4, context[:all_players])
    assert Enum.empty?(matches)
  end

  test "silver with no rank can still match with gold/bronze/unranked", context do
    silver = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: nil}
    silver_no_rank = %Player{context[:s4_player] | leagues: silver}
    matches = Players.get_matches(silver_no_rank, context[:all_players])
    assert length(matches) == 3
    assert Enum.member?(matches, context[:g3_player])
    assert Enum.member?(matches, context[:b5_player])
    assert Enum.member?(matches, context[:unranked_player])
  end
end
