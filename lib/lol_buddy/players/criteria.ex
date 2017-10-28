defmodule LolBuddy.Players.Criteria do
  alias LolBuddy.Players.Player
  defstruct positions: [], voice: false, age_groups: []

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in the backend.
  """
  def from_json(data) do
    %LolBuddy.Players.Criteria{positions: Player.positions_from_json(data["positions"]),
      voice: voice_from_json(data["voiceChat"]),
      age_groups: age_groups_from_json(data["ageGroups"])}
  end


  defp voice_parse("YES"), do: true
  defp voice_parse("NO"), do: false

  @doc """
  Parses the checkbox format the frontend uses for voice criteria,
  into a list of only booleans indicating whether true/false are 
  accepted values for a player's voice field.

  ## Examples
    iex> voice = {"YES" => true, "NO" -> true}
    iex> voice_from_json(voice)
    [true, false]
  """
  def voice_from_json(voice) do
    voice
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> voice_parse(key) end)
  end

  @doc """
  Parses the checkbox format the frontend uses for age_groups.
  Age groups are compared with list intersection, and as such
  we merely return keys for which the value is true

  ## Examples
  iex> age_groups = {"interval1" => true, "interval2" -> true, "interval3" -> false}
  iex> age_groups_from_json(age_groups)
  ["interval1", "interval2"]
  """
  def age_groups_from_json(age_groups) do
    age_groups
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {key,_} -> key end)
  end
end
