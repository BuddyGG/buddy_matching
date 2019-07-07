defmodule BuddyMatching.Players.Info.LolInfo do
  @moduledoc """
  Struct with League of Legends game info.

  Implements `FromJsonBehaviour`.
  """

  require OK
  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  @role_limit 5
  @champion_limit 3

  # This module relies on the atoms defined in the Riot api module,
  # Load_atoms ensues that these are loaded before we use the module
  @on_load :load_atoms
  def load_atoms() do
    Code.ensure_loaded?(RiotApi)
    :ok
  end

  @doc """
  game_criteria => The Player's %LolCriteria.
  positions => A list of the positions the Player plays, eg. [:marksman]
  icon_id => The id of the Player's summoner icon. Used by frontend.
  region => The Player's region as an atom, eg. :euw.
  leagues => The Player's league information.
  champions => The Player's list of champions, eg. ["Vayne", "Caitlyn", "Ezreal"]
  """
  defstruct game_criteria: nil,
            positions: [],
            icon_id: nil,
            region: nil,
            leagues: nil,
            champions: []

  @doc """
  Validates the given JSON map, and passes the %LolInfo{} portion thereof.
  As such, the returned %LolInfo{}, will have `nil` for :game_criteria.

  Returns `%{:ok, %LolInfo{}}` || `{:error, reason}`.
  """
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

  @doc """
  Parses a %LolInfo{} struct from a parsed JSON map.
  This includes the the underlying %LolCriteria.
  If the given map does not conform to expected structure,
  or contains invalid values for the expected fields,
  an error will be returned indicating this.

  Returns `{:ok, %LolInfo{}}` || `{:error, reason}`
  """
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
  # to %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5", wins: 10, losses: 10}
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
