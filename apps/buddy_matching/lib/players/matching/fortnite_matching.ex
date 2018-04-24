defmodule BuddyMatching.Players.Matching.FortniteMatching do
  @moduledoc false

  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Matching
  @behaviour Matching

  def match?(%Player{} = player, %Player{} = candidate) do
    player != candidate
  end
end
