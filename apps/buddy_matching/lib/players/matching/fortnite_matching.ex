defmodule BuddyMatching.Players.Matching.FortniteMatching do
  @moduledoc false

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.MatchingBehaviour
  @behaviour MatchingBehaviour

  def match?(%Player{} = player, %Player{} = candidate) do
    player != candidate
  end
end
