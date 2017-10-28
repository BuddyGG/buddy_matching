defmodule LolBuddy.Players.Criteria do
  alias LolBuddy.Players.Player
  defstruct positions: [], voice: false, age_groups: []

  def from_json(data) do
    %LolBuddy.Players.Criteria{positions: Player.positions_from_json(data["positions"]),
      voice: voice_from_json(data["voiceChat"]),
      age_groups: age_groups_from_json(data["ageGroups"])}
  end

  # Maps a map of structure:
  # {"jungle" => true, "marksman" => false, "mid" => true, "support" => false, "top" => false}
  # To a a list of selected positions as atoms, with above case resulting in:
  # [:top, mid]
  def positions_from_json(positions) do
    positions
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> String.to_atom(key) end)
  end

  defp voice_parse("YES"), do: true
  defp voice_parse("NO"), do: false
  def voice_from_json(voice) do
    voice
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> voice_parse(key) end)
  end

  def age_groups_from_json(age_groups) do
    age_groups
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> key end)
  end
end
