defmodule BuddyMatching.Players.Criteria.FortniteCriteria do
  @moduledoc """
  Struct definining the possible criterias with which Players can
  filter their matches.
  """
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Criteria
  @behaviour Criteria

  @position_limit 5
  @voice_limit 2
  @age_group_limit 3

  defstruct positions: [], voice: [], age_groups: [], ignore_language: false

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in the backend.
  """
  def from_json(data) do
    cond do
      map_size(data["positions"]) > @position_limit ->
        {:error, "Too many positions in criteria"}

      map_size(data["ageGroups"]) > @age_group_limit ->
        {:error, "Too many age groups in criteria"}

      map_size(data["voiceChat"]) > @voice_limit ->
        {:error, "Too many values for voice chat in criteria"}

      true ->
        %BuddyMatching.Players.Criteria.LolCriteria{
          positions: LolInfo.positions_from_json(data["positions"]),
          voice: voice_from_json(data["voiceChat"]),
          age_groups: age_groups_from_json(data["ageGroups"]),
          ignore_language: data["ignoreLanguage"]
        }
    end
  end

  defp voice_parse("YES"), do: true
  defp voice_parse("NO"), do: false

  @doc """
  Parses the checkbox format the frontend uses for voice criteria,
  into a list of only booleans indicating whether true/false are
  accepted values for a player's voice field.

  ## Examples
    iex> voice = {"YES" => true, "NO" => true}
    iex> voice_from_json(voice)
    [true, false]
  """
  def voice_from_json(voice), do: for({val, true} <- voice, do: voice_parse(val))

  @doc """
  Parses the checkbox format the frontend uses for age_groups.
  Age groups are compared with list intersection, and as such
  we merely return keys for which the value is true

  ## Examples
  iex> age_groups = {"interval1" => true, "interval2" -> true, "interval3" -> false}
  iex> age_groups_from_json(age_groups)
  ["interval1", "interval2"]
  """
  def age_groups_from_json(age_groups), do: for({val, true} <- age_groups, do: val)
end
