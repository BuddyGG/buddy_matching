defmodule LolBuddy.PlayersTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria

  # setup some bases for criteria and players that can be used in relation
  # to custom definitions for testing
  setup_all do
    broad_criteria = %Criteria{positions: [:top, :jungle, :mid, :marksman, :support],
      voice: false, age_groups: [1,2,3]}

    narrow_criteria = %Criteria{positions: [:marksman], voice: false, age_groups: [1]}

    master = %{type: "RANKED_SOLO_5x5", tier: "MASTER", rank: 1}
    diamond1 = %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
    platinum4 = %{type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 4}
    gold3 = %{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 3}
    bronze5 = %{type: "RANKED_SOLO_5x5", tier: "BRONZE", rank: 5}

    base_player1 = %Player{id: 1, name: "Lethly", region: :euw, voice: false,
      languages: ["danish"], age_group: 1, positions: [:marksman],
      leagues: [diamond1], champions: ["Vayne", "Ezreal", "Caitlyn"],
      criteria: broad_criteria, comment: "Never dies on Vayne"}

    base_player2 = %Player{id: 2, name: "hansp", region: :euw, voice: false,
      languages: ["danish", "english"], age_group: 1, positions: [:top],
      leagues: [diamond1], champions: ["Cho'Gath", "Renekton", "Riven"],
      criteria: narrow_criteria, comment: "Apparently plays Riven"}

    base_player3 = %Player{id: 3, name: "esow", region: :euw, voice: false,
      languages: ["danish", "english"], age_group: 1, positions: [:top],
      leagues: [diamond1], champions: ["Lee'Sin", "Ekko", "Vayne"],
      criteria: narrow_criteria, comment: "Lul, I'm only Platinum 4"}

    base_player4 = %Player{id: 3, name: "UghUgh", region: :euw, voice: false,
      languages: ["danish", "english"], age_group: 1, positions: [:top],
      leagues: [diamond1], champions: ["Braum", "Leona", "Blitzcrank"],
      criteria: narrow_criteria, comment: "That's okay guys, I'll hit the next one"}

    base_player4 = %Player{id: 3, name: "Froggen", region: :euw, voice: false,
      languages: ["danish", "english"], age_group: 1, positions: [:top],
      leagues: [master], champions: ["LeBlanc", "Syndra", "Fizz"],
      criteria: narrow_criteria, comment: "Haha DDOS Frogger"}

    [player1: base_player1, broad_criteria: broad_criteria, diamond1: diamond1,
     player2: base_player2, narrow_criteria: narrow_criteria]
  end

  @tag :pending
  test "two players match", %{player1: player1, player2: player2} do
    other_players = [player2]

    #other_players should all be matching with player1
    assert ^other_players = Players.get_matches(player1, other_players)
  end

  @tag :pending
  test "multiple matches may be found", %{player1: player1, player2: player2, diamond1: d1} do
    diamond5 = %{d1 | tier: 5}
    player3 = %{player2 | name: "es0w", id: 2, leagues: [diamond5]}
    other_players = [player2, player3]

    #other_players should all be matching with player1
    assert ^other_players = Players.get_matches(player1, other_players)
  end
end
