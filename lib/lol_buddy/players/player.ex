defmodule LolBuddy.Players.Player do
  @moduledoc """
  Struct handling a player including json parsing
  """

  alias LolBuddy.Players.Criteria

  @comment_char_limit 100
  @riot_name_length_limit 16
  @role_limit 5
  @champion_limit 3

  @doc """
  id => A unique identifier for the player
  name => The player's name
  region => The player's region
  voice =>  [true] -> use voice, [false] -> don't use, [true, false] -> don't care
  age_group =>  The player's age group
  leagues =>  A map with the player's queue type, tier and rank
  champions => A list of the player's played champions
  criteria => The given player's %Critera{}
  comment => Potential remarks from the player
  """
  defstruct id: nil,
            name: nil,
            region: nil,
            voice: [],
            languages: [],
            age_group: nil,
            positions: [],
            leagues: nil,
            champions: [],
            criteria: nil,
            comment: nil

  @doc """
  Parses an entire player from json into the Player struct used in the backend,
  including parsing for Criteria into its struct
  """
  def from_json(data) do
    if validate_player_json(data) do
      player = %LolBuddy.Players.Player{
        id: data["userInfo"]["id"],
        name: data["name"],
        region: String.to_existing_atom(data["region"]),
        voice: data["userInfo"]["voicechat"],
        languages: languages_from_json(data["userInfo"]["languages"]),
        age_group: data["userInfo"]["agegroup"],
        positions: positions_from_json(data["userInfo"]["selectedRoles"]),
        leagues: leagues_from_json(data["leagues"]),
        champions: data["champions"],
        criteria: Criteria.from_json(data["userInfo"]["criteria"]),
        comment: data["userInfo"]["comment"]
      }

      {:ok, player}
    else
      {:error, "bad player json"}
    end
  end

  @doc """
  Validates that the given player adheres to the desired structure
  as well as uses limited lengths for most strings. This is solely
  to avoid potential adversarial player submissions that could damage
  the system.

  We do not care if empty lists are submitted, although this should
  generally be avoided in the frontend.
  We additionally don't bother checking things that will be caught
  by crashes in from_json/1.

  Names should adhere to Riot's guidelines:
  https://support.riotgames.com/hc/en-us/articles/201752814-Summoner-Name-FAQ
  """
  def validate_player_json(data) do
    String.length(data["name"]) <= @riot_name_length_limit &&
      map_size(data["userInfo"]["selectedRoles"]) <= @role_limit &&
      length(data["champions"]) <= @champion_limit &&
      (data["userInfo"]["comment"] == nil ||
         String.length(data["userInfo"]["comment"]) <= @comment_char_limit) &&
      Criteria.validate_criteria_json(data["userInfo"]["criteria"])
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

  # Sort the languages alphabetically, but ensure that english is first
  def languages_from_json(languages), do: Enum.sort(languages, &sorter/2)

  defp sorter(_, "EN"), do: false
  defp sorter("EN", _), do: true
  defp sorter(left, right), do: left < right
end
