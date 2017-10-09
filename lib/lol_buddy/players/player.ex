defmodule LolBuddy.Players.Player do
  defstruct id: nil, name: nil, region: nil, voice: false, languages: [],
    age_group: nil, positions: [], leagues: nil, champions: [],
    criteria: nil, comment: ""


  def from_json(data) do
    IO.inspect(data)
    %LolBuddy.Players.Player{id: data["userInfo"]["id"], name: data["name"],
      region: String.to_atom(data["region"]), voice: data["userInfo"]["voicechat"],
      languages: data["userInfo"]["languages"], age_group: data["userInfo"]["agegroup"], 
      positions: positions_from_json(data["userInfo"]["selectedRoles"]),
      leagues: leagues_from_json(data["leagues"]), champions: data["champions"],
      criteria: nil, comment: data["userInfo"]["comment"]}
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

  # Maps a map of structure:
  # {"jungle" => true, "marksman" => false, "mid" => true, "support" => false, "top" => false}
  # To a a list of selected positions as atoms, with above case resulting in:
  # [:top, mid]
  def positions_from_json(positions) do
    positions
    |> IO.inspect
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> String.to_atom(key) end)
  end
end
