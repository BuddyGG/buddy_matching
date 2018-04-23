defmodule BuddyMatching.Players.Info.LolInfo do
  @moduledoc """
  Struct with league of legends game info
  """

  alias BuddyMatching.Players.Info
  @behaviour Info

  defstruct region: nil,
            positions: [],
            leagues: nil,
            champions: []

  def from_json(data) do
    cond do
      true ->
        %BuddyMatching.Players.Info.LolInfo{
          region: String.to_existing_atom(data["region"]),
          positions: positions_from_json(data["userInfo"]["selectedRoles"]),
          leagues: leagues_from_json(data["leagues"]),
          champions: data["champions"]
        }
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
