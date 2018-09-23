defmodule BuddyMatching.Players.Info.FortniteInfo do
  @moduledoc """
  Struct with Fortnite game specific info.

  Implements `FromJsonBehaviour`.
  """

  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  defstruct game_criteria: nil, platform: nil

  @platforms %{"pc" => :pc, "ps4" => :ps4, "xbox" => :xb1}

  def from_json(data) do
    if Map.has_key?(@platforms, data["platform"]) do
      {:ok,
       %BuddyMatching.Players.Info.FortniteInfo{
         platform: @platforms[data["platform"]]
       }}
    else
      platforms = Map.keys(@platforms)
      {:error, "Platform should be one of #{inspect(platforms)}"}
    end
  end
end
