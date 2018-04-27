defmodule BuddyMatching.Players.Info.LolInfo do
  @moduledoc """
  Struct with League of Legends game info
  """

  require OK
  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  @role_limit 5
  @champion_limit 3

  defstruct game_criteria: nil,
            positions: [],
            icon_id: nil,
            region: nil,
            leagues: nil,
            champions: []

  def lol_info_from_json(data) do
    cond do
      map_size(data["selectedRoles"]) > @role_limit ->
        {:error, "Too many roles selected"}

      length(data["champions"]) > @champion_limit ->
        {:error, "Too many champions"}

      true ->
        {:ok,
         %BuddyMatching.Players.Info.LolInfo{
           positions: positions_from_json(data["selectedRoles"]),
           icon_id: data["iconId"],
           leagues: leagues_from_json(data["leagues"]),
           region: String.to_existing_atom(data["region"]),
           champions: data["champions"]
         }}
    end
  end

  def from_json(data) do
    OK.for do
      info <- lol_info_from_json(data)
      criteria <- LolCriteria.from_json(data["gameCriteria"])
    after
      %BuddyMatching.Players.Info.LolInfo{info | game_criteria: criteria}
    end
  end

  # Parses a json leagues specification of format:
  # "leagues" => %{"rank" => 1, "tier" => "GOLD", "type" => "RANKED_SOLO_5x5"}
  # to %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"}
  defp leagues_from_json(leagues) do
    leagues
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
  end

  @doc """
  Parses positions given as json into the atom list format used for positions
  for the Player struct.

  ## Examples
    iex> positions = {"jungle" => true, "marksman" => false,
      "mid" => true, "support" => false, "top" => false}
    iex> positions_from_json(positions)
    [:jungle, :mid]
  """
  def positions_from_json(positions),
    do: for({val, true} <- positions, do: String.to_existing_atom(val))
end
