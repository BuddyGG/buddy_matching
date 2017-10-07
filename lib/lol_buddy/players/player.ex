defmodule LolBuddy.Players.Player do
  defstruct id: nil, name: nil, region: nil, voice: false, languages: [],
    age_group: nil, positions: [], leagues: nil, champions: [],
    criteria: nil, comment: ""

  def from_json(json) do
    data = json

    %LolBuddy.Players.Player{id: data["userInfo"]["id"], name: data["name"],
    region: String.to_atom(data["region"]), voice: data["userInfo"]["voicechat"],
    languages: data["userInfo"]["languages"], age_group: data["userInfo"]["agegroup"], positions: positions_from_json(data["userInfo"]["selectedRoles"]),
    leagues: leagues_from_json(data["leagues"]), 
    champions: data["champions"],criteria: nil, comment: data["userInfo"]["comment"]}
  end
  
  defp leagues_from_json(legues) do
    legues 
    |>  Enum.map(
        fn elem -> elem 
                   |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
                   |> Enum.into(%{})
        end)
  end

  defp positions_from_json(positions) do
    positions
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> key end)
  end
end
