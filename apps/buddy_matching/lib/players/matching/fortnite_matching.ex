defmodule BuddyMatching.Players.Matching.FortniteMatching do
  @moduledoc false

  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.MatchingBehaviour
  @behaviour MatchingBehaviour

  @doc """
  Checks whether 2 FortniteInfos are compatible. This is done by
  checking platform compatability, as well as mutual criteria compatability.
  """
  def match?(%FortniteInfo{} = player, %FortniteInfo{} = candidate) do
    player.platform == candidate.platform && criteria_compatible?(player.game_criteria, candidate) &&
      criteria_compatible?(candidate.game_criteria, player)
  end

  @doc """
  Checks whether a FortniteCriteria is valid for queuing with the given FortniteInfo.
  In practise this determines whether the minimum games played in the criteria is met
  by the given FortniteInfo.

  ## Examples
    iex> info = %FortniteInfo{games_played: 12}
    iex> criteria = %FortniteCriteria{min_games_played: 10}
    iex> criteria_compatible?(criteria, info)
    true
  """
  def criteria_compatible?(%FortniteCriteria{} = criteria, %FortniteInfo{} = info) do
    criteria.min_games_played <= info.games_played
  end
end
