defmodule BuddyMatching.PlayersTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Criteria.PlayerCriteria
  alias BuddyMatching.Players.Criteria.LolCriteria

  # The intrinsics of matchings are covered in matching specific tests,
  # as such these tests are aimed at tests on lists of players through the
  # Players module.
  setup_all do
    broad_criteria = %PlayerCriteria{
      age_groups: [1, 2, 3],
      voice: [false, true],
      ignore_language: false
    }

    broad_game_criteria = %LolCriteria{positions: [:top, :jungle, :mid, :marksman, :support]}

    challenger = %{type: "RANKED_SOLO_5x5", tier: "CHALLENGER", rank: nil}
    master = %{type: "RANKED_SOLO_5x5", tier: "MASTER", rank: nil}
    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
    platinum2 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 2}
    gold3 = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 3}
    silver4 = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: 4}
    bronze5 = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 5}
    unranked = %{type: "RANKED_SOLO_5x5", tier: "UNRANKED", rank: 4}

    player0 = %Player{
      id: 0,
      name: "Faker",
      voice: [false],
      languages: ["danish"],
      age_group: 1,
      comment: "numero uno",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        leagues: challenger,
        positions: [:mid],
        champions: ["LeBlanc", "Syndra", "Fizz"]
      }
    }

    player1 = %Player{
      id: 1,
      name: "Froggen",
      voice: [false],
      comment: "Haha DDOS Frogger",
      languages: ["danish"],
      age_group: 1,
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:mid],
        leagues: master,
        champions: ["LeBlanc", "Syndra", "Fizz"]
      }
    }

    player2 = %Player{
      id: 2,
      name: "Lethly",
      voice: [false],
      languages: ["danish", "english"],
      comment: "Never dies on Vayne",
      age_group: 1,
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:marksman],
        leagues: diamond1,
        champions: ["Vayne", "Ezreal", "Caitlyn"]
      }
    }

    player3 = %Player{
      id: 3,
      name: "hansp",
      voice: [false],
      languages: ["danish", "english"],
      age_group: 1,
      comment: "Apparently plays Riven",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:top],
        leagues: platinum2,
        champions: ["Cho'Gath", "Renekton", "Riven"]
      }
    }

    player4 = %Player{
      id: 4,
      name: "esow",
      voice: [false],
      languages: ["danish", "english"],
      age_group: 1,
      comment: "Lul, I'm only Platinum 4",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:jungle],
        leagues: gold3,
        champions: ["Lee'Sin", "Ekko", "Vayne"]
      }
    }

    player5 = %Player{
      id: 5,
      name: "UghUgh",
      age_group: 1,
      voice: [false],
      languages: ["danish", "english"],
      comment: "That's okay guys, I'll hit the next one",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:support],
        leagues: silver4,
        champions: ["Braum", "Leona", "Blitzcrank"]
      }
    }

    player6 = %Player{
      id: 6,
      name: "xm3m3l0rd69x",
      voice: [false],
      languages: ["danish", "english"],
      age_group: 1,
      comment: "Am in elo hell, but am good",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:mid, :marksman],
        leagues: bronze5,
        champions: ["Yasuo", "Riven", "Vayne"]
      }
    }

    player7 = %Player{
      id: 7,
      name: "LordOfDeathIThink",
      voice: [false],
      languages: ["danish", "english"],
      age_group: 1,
      comment: "I don't play very much",
      criteria: broad_criteria,
      game_info: %LolInfo{
        region: :euw,
        game_criteria: broad_game_criteria,
        positions: [:jungle],
        leagues: unranked,
        champions: ["Yasuo", "Riven", "Vayne"]
      }
    }

    all_players = [
      player0,
      player1,
      player2,
      player3,
      player4,
      player5,
      player6,
      player7
    ]

    [
      challenger_player: player0,
      master_player: player1,
      d1_player: player2,
      p2_player: player3,
      g3_player: player4,
      s4_player: player5,
      b5_player: player6,
      unranked_player: player7,
      all_players: all_players
    ]
  end

  test "two players match", %{p2_player: player1, g3_player: player2} do
    other_players = [player2]

    # other_players should all be matching with player1
    assert other_players == Players.get_matches(player1, other_players)
  end

  test "challenger player matches only master and d1 player", context do
    matches = Players.get_matches(context[:challenger_player], context[:all_players])
    assert length(matches) == 2
    assert Enum.member?(matches, context[:master_player])
    assert Enum.member?(matches, context[:d1_player])
  end

  test "master player matches only challenger and d1 player", context do
    matches = Players.get_matches(context[:master_player], context[:all_players])
    assert length(matches) == 2
    assert Enum.member?(matches, context[:challenger_player])
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
    narrow_game_criteria = %LolCriteria{positions: [:support]}
    narrow_criteria = %PlayerCriteria{voice: [true], age_groups: [3]}
    narrow_s4 = %Player{context[:s4_player] | criteria: narrow_criteria}
    narrow_s4 = put_in(narrow_s4.game_info.game_criteria, narrow_game_criteria)
    matches = Players.get_matches(narrow_s4, context[:all_players])
    assert Enum.empty?(matches)
  end

  test "silver with no rank can still match with gold/bronze/unranked", context do
    silver = %{type: "RANKED_SOLO_5x5", tier: "SILVER", rank: nil}
    game_info = %LolInfo{context[:s4_player].game_info | leagues: silver}
    silver_no_rank = %Player{context[:s4_player] | game_info: game_info}
    matches = Players.get_matches(silver_no_rank, context[:all_players])
    assert length(matches) == 3
    assert Enum.member?(matches, context[:g3_player])
    assert Enum.member?(matches, context[:b5_player])
    assert Enum.member?(matches, context[:unranked_player])
  end
end
