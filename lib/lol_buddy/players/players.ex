defmodule LolBuddy.Players do
  #alias LolBuddy.Players.Matching

  # TODO implement logic
  # And perhaps, this method should not even be here?
  # -- find_matches seem the only relevant interface to Players module
  def match?(player, candidate) do
    player.id != candidate.id
  end

  # TODO implement logic
  def find_matches(player, other_players) do
      other_players
  end
end
