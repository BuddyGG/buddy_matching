defmodule BuddyMatching.Players.Matching.LolMatching do
  @moduledoc """
  Module containing all logic for determining whether two %LolInfo{}'s match.
  This included handling whether or not they can play with eachother based
  on Riot's own rules on the matter:
    https://support.riotgames.com/hc/en-us/articles/204010760-Ranked-Play-FAQ
  and whether LolInfo's LolCriteria are mutually compatible.

  Implements `MatchingBehaviour`.
  """
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.MatchingBehaviour
  @behaviour MatchingBehaviour

  @loose_tiers ["UNRANKED", "BRONZE", "SILVER", "GOLD", "PLATINUM"]

  @doc """
  Returns a boolean representing whether LolInfo's 'player' and 'candidate'
  are able to play together and fit eachother's criteria.

  ## Examples
    iex> criteria1 = %LolCriteria{positions: [:support]}
    iex> info1 = %LolInfo{game_criteria: criteria1, positions: [:marksman],
      leagues: %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}}
    iex> criteria2 = %LolCriteria{positions: [:marksman]}
    iex> info2 = %LolInfo{game_criteria: criteria2, positions: [:support],
      leagues: %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 3}}
    iex> BuddyMatching.Players.Matching.match(info1, info2)
    true

  """
  def match?(%LolInfo{} = player_info, %LolInfo{} = candidate_info) do
    can_queue?(player_info, candidate_info) &&
      criteria_compatible?(player_info.game_criteria, candidate_info) &&
      criteria_compatible?(candidate_info.game_criteria, player_info)
  end

  # Convert two lists to MapSets and see if they intersect?
  defp lists_intersect?(a, b) do
    !MapSet.disjoint?(MapSet.new(a), MapSet.new(b))
  end

  # Helper for extracting solo queue and determining if it
  # is possible for two players to queue together
  defp can_queue?(%LolInfo{} = info1, %LolInfo{} = info2) do
    if info1.region == info2.region do
      tier_compatible?(info1.leagues, info2.leagues)
    else
      false
    end
  end

  @doc """
  Returns a boolean representing whether the %LolInfo 'player'
  conforms to the %LolCriteria 'criteria'.

  ## Examples
    iex> criteria = %LolCriteria{positions: [:marksman]}
    iex> info = %LolInfo{game_criteria: criteria, positions: [:marksman],
      leagues: %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}}
    iex> BuddyMatching.Players.Matching.criteria_compatible?(criteria, info)
    true

  """
  def criteria_compatible?(%LolCriteria{} = criteria, %LolInfo{} = info) do
    lists_intersect?(criteria.positions, info.positions)
  end

  # This function assumes high isn't in @loose_tiers and that
  # high and low are at most 1 league apart. This should be and is handled
  # in tier_compatible?/2.
  #
  # Defined according to below
  # https://support.riotgames.com/hc/en-us/articles/204010760-Ranked-Play-FAQ
  # Helper for handling special restrictions for cases
  # when the players queuing have a tier discrepancy of 1
  defp rank_compatible?(%{tier: ht} = high, %{tier: lt} = low) do
    hr = get_rank(high)
    lr = get_rank(low)

    cond do
      # master and challenger have equal restrictions
      ht == "MASTER" || ht == "CHALLENGER" -> lr in 1..3
      # now we may can assume ht is diamond
      # we also know if hr is diamond, lt has to be platinum
      hr == 1 -> ht == lt && lr in 1..4
      # d2 can't queue with plat (shouldn't happen tho)
      hr == 2 -> false
      # d3 can queue with plat 1
      hr == 3 -> lr == 1
      # d4 can queue with plat 1/2
      hr == 4 -> lr in 1..2
      # d5 can queue with plat 1..3
      hr == 5 -> lr in 1..3
    end
  end

  @doc """
  Returns a boolean indicating whether the given leagues are able to queue together.

  ## Examples
      iex> league1 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
      iex> league2 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> BuddyMatching.Players.Matching.tier_compatible?(league1, league2)
      true

      iex> league3 = {type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
      iex> league4 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> BuddyMatching.Players.Matching.tier_compatible?(league3, league4)
      false
  """
  def tier_compatible?(league1, league2) do
    {h, l} = sort_leagues(league1, league2)
    tier_diff = tier_to_int(h.tier) - tier_to_int(l.tier)

    cond do
      # special handling for d1 as it cannot queue with its entire league
      h.tier == "DIAMOND" && get_rank(h) == 1 ->
        rank_compatible?(h, l)

      tier_diff == 0 ->
        true

      tier_diff == 1 ->
        if h.tier in @loose_tiers, do: true, else: rank_compatible?(h, l)

      true ->
        false
    end
  end

  @doc """
  Returns the input sorted as a tuple {high, low}
  If they are equal, league1 is returned as highest

  ## Examples
      iex> gold1 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
      iex> gold2 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> BuddyMatching.Players.Matching.sort_leagues(gold1, gold2)
      {gold1, gold2}
  """
  def sort_leagues(league1, league2) do
    tier1 = tier_to_int(league1.tier)
    tier2 = tier_to_int(league2.tier)

    cond do
      tier1 > tier2 ->
        {league1, league2}

      tier2 > tier1 ->
        {league2, league1}

      true ->
        if league1.rank <= league2.rank,
          do: {league1, league2},
          else: {league2, league1}
    end
  end

  defp tier_to_int(tier) do
    case tier do
      "BRONZE" -> 1
      # Riot treats unrankeds like silvers
      "UNRANKED" -> 2
      "SILVER" -> 2
      "GOLD" -> 3
      "PLATINUM" -> 4
      "DIAMOND" -> 5
      "MASTER" -> 6
      "CHALLENGER" -> 6
    end
  end

  # Handle players where we don't know their rank but only their league as rank 5
  defp get_rank(%{rank: nil}), do: 5
  defp get_rank(%{rank: rank}), do: rank
end
