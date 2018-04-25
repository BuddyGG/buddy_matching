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

  defp game_match?(%Player{game: :fortnite} = player, %Player{game: :fortnite} = candidate) do
    FortniteMatching.match?(player, candidate)
  end

  defp game_match?(%Player{game: :lol} = player, %Player{game: :lol} = candidate) do
    LolMatching.match?(player, candidate)
  end

  def match?(%Player{} = player, %Player{} = candidate) do
    PlayerMatching.match?(player, candidate) && game_match?(player, candidate)
  end

  def get_matches(player, other_players) do
    Enum.filter(other_players, &BuddyMatching.Players.match?(player, &1))
  end
end
