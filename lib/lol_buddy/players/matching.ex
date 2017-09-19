defmodule LolBuddy.Players.Matching do
  alias LolBuddy.Player
  # resource for who can play with who
  # https://support.riotgames.com/hc/en-us/articles/204010760-Ranked-Play-FAQ

  # TODO logic
  def match?(%Player{} = player, %Player{} = candidate) do
      player.id != candidate.id
    cond do
      player.id == candidate.id -> false
      !can_queue?(player, candidate) -> false
      list_intersection(player.languages, candidate.languages) == [] -> false
      true -> criteria_compatible?(player, candidate)
    end
  end

  # convert to lists to MapSets and intersect them
  defp list_intersection(a, b) do
    MapSet.intersection(MapSet.new(a), MapSet.new(b))
  end

  # TODO logic
  defp can_queue?(%Player{} = player, %Player{} = candidate) do
    true
    cond do
      player.region != candidate.region -> false
      true -> !tier_compatible?(player.leagues, candidate.leagues)
    end
  end

  # TODO logic
  defp criteria_compatible?(%Player{} = player, %Player{} = candidate) do
      player.id != candidate.id
  end


  # Defined according to below
  # https://support.riotgames.com/hc/en-us/articles/204010760-Ranked-Play-FAQ
  # Helper for handling special restrictions for cases
  # when the players queuing have a tier discrepancy of 1
  defp rank_compatible?(%{tier: ht, rank: hr}, %{tier: lt, rank: lr}) do
    loose_tiers = ["BRONZE", "SILVER", "GOLD", "PLATINUM"]
    cond do
      ht in loose_tiers -> true
      ht == "CHALLENGER" -> false # always reject
      ht == "MASTER" -> lr in 1..3

      # now we may can assume ht is diamond
      # we also know if hr is diamond, lt has to be platinum
      hr == 1 -> ht == lt && lr in 1..4
      hr == 2 -> false      # d2 can't queue with plat (should never be called tho)
      hr == 3 -> lr == 1    # d3 can queue with plat 1
      hr == 4 -> lr in 1..2 # d4 can queue with plat 1/2
      hr == 5 -> lr in 1..3 # d5 can queue with plat 1..3
    end
  end

  @doc """
  Returns a boolean indicating whether the given leagues are able to queue together.

  ## Examples
      iex> league1 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
      iex> league2 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> LolBuddy.Players.Matching.tier_compatible?(league1, league2)
      true

      iex> league3 = {type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}
      iex> league4 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> LolBuddy.Players.Matching.tier_compatible?(league3, league4)
      false
  """
  def tier_compatible?(league1, league2) do
    {h, l} = sort_league(league1, league2)
    ht = tier_to_int(h.tier)
    lt = tier_to_int(l.tier)

    # challenger's may only walk alone
    cond do
      h.tier == "CHALLENGER" -> false
      # special handling for d1 as it cannot queue with its entire league
      h.tier == "DIAMOND" && h.rank == 1 -> rank_compatible?(h, l)
      ht - lt == 0 -> true
      ht - lt == 1 -> rank_compatible?(h, l)
      true -> false
    end
  end

  @doc """
  Returns the input sorted as a tuple {high, low}
  If they are equal, league1 is returned as highest

  ## Examples
      iex> league1 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}
      iex> league2 = {type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 2}
      iex> LolBuddy.Players.Matching.sort_league(league1, league2)
      {league1, league2}
  """
  def sort_league(league1, league2) do
    tier1 = tier_to_int(league1.tier)
    tier2 = tier_to_int(league2.tier)
    cond do
      tier1 > tier2 -> {league1, league2}
      tier2 > tier1 -> {league2, league1}
      true -> if (league1.rank <= league2.rank),
              do: {league1, league2},
              else: {league2, league1}
    end
  end

  defp tier_to_int(tier) do
    case tier do
      "BRONZE"     -> 1
      "SILVER"     -> 2
      "GOLD"       -> 3
      "PLATINUM"   -> 4
      "DIAMOND"    -> 5
      "MASTER"     -> 6
      "CHALLENGER" -> 7
    end
  end
end
