defmodule LolBuddy.Players do
  alias LolBuddy.Players.Matching

  def get_matches(player, other_players) do
    #Enum.filter(other_players, &(Matching.match?(player, &1)))
    other_players
  end
end
