defmodule LolBuddy.Players do
    alias LolBuddy.Player

    def player_match?(%Player{} = _player, %Player{} = _candidate) do
        true
    end
end