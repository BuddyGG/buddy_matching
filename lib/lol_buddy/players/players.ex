defmodule LolBuddy.Players do
    alias LolBuddy.Player

    ##TODO implement real logic
    def match?(%Player{} = player, %Player{} = candidate) do
        player.id != candidate.id
    end

    def find_matches(player, other_players) do
        other_players
    end
end
