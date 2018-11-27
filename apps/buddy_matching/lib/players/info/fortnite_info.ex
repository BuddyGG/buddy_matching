defmodule BuddyMatching.Players.Info.FortniteInfo do
  @moduledoc """
  Struct with Fortnite game specific info.

  Implements `FromJsonBehaviour`.
  """

  require OK
  alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  defstruct game_criteria: nil,
            platform: nil,
            games_played: 0,
            solo: %{},
            duo: %{},
            squad: %{},
            total: %{}

  @platforms %{"pc" => :pc, "ps4" => :ps4, "xbox" => :xb1}

  @doc """
  Validates the given JSON map, and passes the %FortniteInfo{} portion thereof.
  As such, the returned %FortniteInfo, will have `nil` for :game_criteria.

  Returns `%{:ok, %FortniteInfo{}}` || `{:error, reason}`.
  """
  def fortnite_info_from_json(data) do
    if Map.has_key?(@platforms, Map.get(data, "platform")) do
      {:ok,
       %BuddyMatching.Players.Info.FortniteInfo{
         platform: @platforms[data["platform"]],
         games_played: data["gamesPlayed"],
         solo: Map.get(data, "solo", %{}),
         duo: Map.get(data, "duo", %{}),
         squad: Map.get(data, "squad", %{}),
         total: Map.get(data, "total", %{})
       }}
    else
      platforms = Map.keys(@platforms)
      {:error, "Platform should be one of #{inspect(platforms)}"}
    end
  end

  @doc """
  Parses a %FortniteInfo{} struct from a parsed JSON map.
  This includes some error handling, such as checking whether the given
  platform is one that we support.The underlying gameCriteria, in

  Returns `{:ok, %FortniteInfo{}}` || `{:error, reason}`
  """
  def from_json(data) do
    OK.for do
      info <- fortnite_info_from_json(data)
      criteria <- FortniteCriteria.from_json(data["gameCriteria"])
    after
      %BuddyMatching.Players.Info.FortniteInfo{info | game_criteria: criteria}
    end
  end
end
