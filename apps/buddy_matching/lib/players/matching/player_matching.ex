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

  @doc """
  Determines whether the given criteria is compatible with the given player (candidate).
  """
  def criteria_compatible?(%PlayerCriteria{} = criteria, %Player{} = candidate) do
    lists_intersect?(criteria.voice, candidate.voice) &&
      Enum.member?(criteria.age_groups, candidate.age_group)
  end

  @doc """
  Determines whether the given players are language compatible.
  This includes checking for whether both players want to ignore language
  compatability.
  """
  def language_compatible?(%Player{} = player, %Player{} = candidate) do
    lists_intersect?(player.languages, candidate.languages) ||
      (player.criteria.ignore_language && candidate.criteria.ignore_language)
  end

  @doc """
  Returns a boolean representing whether Player 'player' and Player 'candidate'
  are able to play together and fit eachother's criteria.

  ## Examples
    iex> c = %PlayerCriteria{voice: [true], age_groups: ["1"], ignore_language: false}
    iex> p1 = %Player{id: 1, languages: ["DK"], criteria: c, voice: [true], age_group: "1"}
    iex> p2 = %Player{id: 2, languages: ["DK", "BR"], criteria: c, voice: [true], age_group: "1"}
    iex> match?(p1, p2)
    true
    iex> p3 = %Player{p1 | age_group: "2"}
    iex> match?(p2, p3)
    false
  """
  def match?(%Player{} = player, %Player{} = candidate) do
    player.id != candidate.id && language_compatible?(player, candidate) &&
      criteria_compatible?(player.criteria, candidate) &&
      criteria_compatible?(candidate.criteria, player)
  end
end
