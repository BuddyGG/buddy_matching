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


  # TODO -> define according to below
  # https://support.riotgames.com/hc/en-us/articles/204010760-Ranked-Play-FAQ
  def rank_compatible?(high, low) do
    true
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
    {high, low} = sort_league(league1, league2)
    high_tier = tier_to_int(high.tier)
    low_tier = tier_to_int(low.tier)
    case high_tier - low_tier do
      0 -> true
      x when x > 1 -> false
      1 -> rank_compatible?(high, low)
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
