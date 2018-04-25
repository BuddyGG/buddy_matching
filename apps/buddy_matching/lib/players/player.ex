defmodule BuddyMatching.Players.Player do
  @moduledoc """
  Struct handling a player including json parsing
  """

  require OK

  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo

  @comment_char_limit 100
  @riot_name_length_limit 16
  @role_limit 5
  @language_limit 5
  @champion_limit 3

  # This module relies on the atoms defined in the Riot api module,
  # Load_atoms ensues that these are loaded before we use the module
  @on_load :load_atoms
  def load_atoms() do
    Code.ensure_loaded?(RiotApi)
    :ok
  end

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
            game: :lol,
            voice: [],
            languages: [],
            age_group: [],
            criteria: %{},
            comment: nil,
            game_info: %{}

  # Sort the languages alphabetically, but ensure that english is first
  def languages_from_json(languages), do: Enum.sort(languages, &sorter/2)

  defp sorter(_, "EN"), do: false
  defp sorter("EN", _), do: true
  defp sorter(left, right), do: left < right

  @doc """
  Validates that the given player adheres to the desired structure
  as well as uses limited lengths for most strings and lists. This is
  solely to avoid potential adversarial player submissions that could
  damage the system.

  We do not care if empty lists are submitted, although this should
  generally be avoided in the frontend.
  We additionally don't bother checking things that will be caught
  by crashes in from_json/1.

  Names should adhere to Riot's guidelines:
  https://support.riotgames.com/hc/en-us/articles/201752814-Summoner-Name-FAQ
  """
  def player_from_json(data) do
    cond do
      String.length(data["name"]) > @riot_name_length_limit ->
        {:error, "Name too long"}

      map_size(data["userInfo"]["selectedRoles"]) > @role_limit ->
        {:error, "Too many roles selected"}

      length(data["userInfo"]["languages"]) > @language_limit ->
        {:error, "Too many langauges"}

      length(data["champions"]) > @champion_limit ->
        {:error, "Too many champions"}

      data["userInfo"]["comment"] != nil &&
          String.length(data["userInfo"]["comment"]) > @comment_char_limit ->
        {:error, "Comment too long"}

      true ->
        {:ok,
         %BuddyMatching.Players.Player{
           id: data["userInfo"]["id"],
           game: String.to_existing_atom(data["game"]),
           name: data["name"],
           voice: data["userInfo"]["voicechat"],
           languages: languages_from_json(data["userInfo"]["languages"]),
           age_group: data["userInfo"]["agegroup"],
           comment: data["userInfo"]["comment"]
         }}
    end
  end

  def info_from_json(:lol, data), do: LolInfo.from_json(data)
  def info_from_json(:fortnite, data), do: FortniteInfo.from_json(data)
  def criteria_from_json(:lol, data), do: LolCriteria.from_json(data)
  def criteria_from_json(:fortnite, data), do: FortniteCriteria.from_json(data)

  @doc """
  Parses an entire player from json into the Player struct used in the backend,
  including parsing for Criteria into its struct
  """
  def from_json(data) do
    OK.for do
      player <- player_from_json(data)
      game_info <- info_from_json(player.game, data)
      criteria <- criteria_from_json(player.game, data["userInfo"]["criteria"])
    after
      %BuddyMatching.Players.Player{player | game_info: game_info, criteria: criteria}
    end
  end
end
