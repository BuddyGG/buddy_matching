defmodule BuddyMatching.Players do
  @moduledoc """
  Api calls related to a player
  """

  alias BuddyMatching.Players.Matching.LolMatching

  def get_matches(player, other_players) do
    Enum.filter(other_players, &LolMatching.match?(player, &1))
  end
end
