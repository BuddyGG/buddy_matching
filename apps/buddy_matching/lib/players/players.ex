defmodule BuddyMatching.Players do
  @moduledoc """
  Module responsible for glueing together the various
  game specific matching alongside the general Player matching.

  Exposes `match?/2` for matching between two players
  and `get_matches?/2` for matching between a single player
  and a list of players.
  """
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Matching.PlayerMatching
  alias BuddyMatching.Players.Matching.LolMatching
  alias BuddyMatching.Players.Matching.FortniteMatching
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo

  # Handles game specific matches, by passing long
  # the player and candidate to the responsible matching module
  # based on the type of the game_info.
  defp game_match?(player, candidate) do
    case {player.game_info, candidate.game_info} do
      {%LolInfo{}, %LolInfo{}} ->
        LolMatching.match?(player.game_info, candidate.game_info)

      {%FortniteInfo{}, %FortniteInfo{}} ->
        FortniteMatching.match?(player.game_info, candidate.game_info)

      _otherwise ->
        false
    end
  end

  def match?(%Player{} = player, %Player{} = candidate) do
    PlayerMatching.match?(player, candidate) && game_match?(player, candidate)
  end

  def get_matches(player, other_players) do
    Enum.filter(other_players, &BuddyMatching.Players.match?(player, &1))
  end
end
