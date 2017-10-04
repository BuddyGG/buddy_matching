defmodule LolBuddy.Players.Player do
  defstruct id: nil, name: nil, region: nil, voice: false, languages: [],
    age_group: nil, positions: [], leagues: nil, champions: [],
    criteria: nil, comment: ""

  def from_json(json) do
    data = Poison.Parser.parse!(json)

    %LolBuddy.Players.Player{id: data["id"], name: data["name"],
    region: String.to_atom(data["region"]), voice: data["voice"],
    languages: data["languages"], age_group: data["age_group"], positions: positions_from_json(data["positions"]),
    leagues: leagues_from_json(data["leagues"]), 
    champions: data["champions"],criteria: nil, comment: data["comment"]}
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
