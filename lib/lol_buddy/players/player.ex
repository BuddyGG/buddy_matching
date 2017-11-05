defmodule LolBuddy.Players.Player do
  alias LolBuddy.Players.Criteria
  defstruct id: nil, name: nil, region: nil, voice: false, languages: [],
    age_group: nil, positions: [], leagues: [], champions: [],
    criteria: nil, comment: ""

  @doc """
  Parses an entire player from json into the Player struct used in the backend,
  including parsing for Criteria into its struct
  """
  def from_json(data) do
    %LolBuddy.Players.Player{id: data["userInfo"]["id"], name: data["name"],
      region: String.to_atom(data["region"]), voice: data["userInfo"]["voicechat"],
      languages: languages_from_json(data["userInfo"]["languages"]), age_group: data["userInfo"]["agegroup"], 
      positions: positions_from_json(data["userInfo"]["selectedRoles"]),
      leagues: leagues_from_json(data["leagues"]), champions: data["champions"],
      criteria: Criteria.from_json(data["userInfo"]["criteria"]), comment: data["userInfo"]["comment"]}
  end
  
  # Parses a json leagues specification of format:
  # ..."leagues" => [%{"rank" => 1, "tier" => "GOLD", "type" => "RANKED_SOLO_5x5"}]...
  # to [%{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"}]
  defp leagues_from_json(leagues) do
    leagues 
    |>  Enum.map(
        fn elem -> elem 
                   |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
                   |> Enum.into(%{})
        end)
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
  def positions_from_json(positions), do: for {val, true} <- positions, do: String.to_atom(val)

  # Sort the languages alphabetically, but ensure that english is first
  def languages_from_json(languages), do: Enum.sort(languages, &sorter/2)

  defp sorter(_,"EN"), do: false
  defp sorter("EN",_), do: true 
  defp sorter(left,right), do: left < right

end
