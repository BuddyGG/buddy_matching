defmodule BuddyMatching.Players.Matching.FortniteMatching do
  @moduledoc false

  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.MatchingBehaviour
  @behaviour MatchingBehaviour

  def match?(%FortniteInfo{} = player, %FortniteInfo{} = candidate) do
    player.platform == candidate.platform
  end
end
