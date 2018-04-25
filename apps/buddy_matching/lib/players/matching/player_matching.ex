defmodule BuddyMatching.Players.Matching.PlayerMatching do
  @moduledoc """
  Module containing all logic for matching of the general case Player.
  """
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Criteria.PlayerCriteria
  alias BuddyMatching.Players.MatchingBehaviour
  @behaviour MatchingBehaviour

  @doc """
  Function for checking whether two lists' values intersect.

  ## Examples
    iex> lists_intersect?([1,2,3], [3,4,5])
    true
    iex> lists_intersect?([1,2,3], [4,5,6])
    false
  """
  def lists_intersect?(a, b) do
    !MapSet.disjoint?(MapSet.new(a), MapSet.new(b))
  end

  def criteria_compatible?(%PlayerCriteria{} = criteria, %Player{} = candidate) do
    lists_intersect?(criteria.voice, candidate.voice) &&
      Enum.member?(criteria.age_groups, candidate.age_group)
  end

  @doc """
  Returns a boolean representing whether Player 'player' and Player 'candidate'
  are able to play together and fit eachother's criteria.

  ## Examples
    iex> p1 = %Player{server: :a, languages: ["DK"]}
    iex> p2 = %Player{server: :a, languages: ["DK", "BR"]}
    iex> match?(p1, p2)
    true
    iex> p3 = %Player{server: :b, languages: ["DK", "BR"]}
    iex> match?(p2, p3)
    false
  """
  def match?(%Player{} = player, %Player{} = candidate) do
    player.server == candidate.server &&
      (lists_intersect?(player.languages, candidate.languages) ||
         (player.criteria.ignore_language && candidate.criteria.ignore_language)) &&
      criteria_compatible?(player.criteria, candidate) &&
      criteria_compatible?(candidate.criteria, player)
  end
end
