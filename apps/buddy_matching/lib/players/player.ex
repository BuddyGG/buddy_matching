defmodule BuddyMatching.Players.Player do
  @moduledoc """
  Struct handling a player including json parsing
  """

  require OK

  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatching.Players.Criteria.FortniteCriteria
  alias BuddyMatching.Players.Criteria.PlayerCriteria
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Info.FortniteInfo
  alias BuddyMatching.Players.FromJsonBehaviour

  @behaviour FromJsonBehaviour

  @name_limit 16
  @language_limit 5
  @comment_char_limit 100

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
  game => Atom representing the game the player is matching for, eg. :lol
  voice =>  [true] -> use voice, [false] -> don't use, [true, false] -> don't care
  languages => A list of the player's spoken languages
  age_group => The given player's current age group
  comment => Potential remarks from the player
  criteria => The given player's %PlayerCritera{}
  game_info => The given player's game specific info. Eg. %LolInfo{}.
  """
  defstruct id: nil,
            name: nil,
            game: nil,
            voice: [],
            languages: [],
            age_group: nil,
            comment: nil,
            criteria: %{},
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
      String.length(data["name"]) > @name_limit ->
        {:error, "Name too long"}

      length(data["languages"]) > @language_limit ->
        {:error, "Too many langauges"}

      data["comment"] != nil && String.length(data["comment"]) > @comment_char_limit ->
        {:error, "Comment too long"}

      true ->
        {:ok,
         %BuddyMatching.Players.Player{
           id: data["id"],
           name: data["name"],
           game: String.to_existing_atom(data["game"]),
           voice: data["voiceChat"],
           languages: languages_from_json(data["languages"]),
           age_group: data["ageGroup"],
           comment: data["comment"]
         }}
    end
  end

  def info_from_json(:fortnite, gameInfo), do: FortniteInfo.from_json(gameInfo)
  def info_from_json(:lol, gameInfo), do: LolInfo.from_json(gameInfo)

  def game_criteria_from_json(:fortnite, criteria), do: FortniteCriteria.from_json(criteria)
  def game_criteria_from_json(:lol, criteria), do: LolCriteria.from_json(criteria)

  @doc """
  Parses an entire player from json into the Player struct used in the backend,
  including parsing for Criteria into its struct
  """
  def from_json(data) do
    OK.for do
      player <- player_from_json(data)
      game_info <- info_from_json(player.game, data["gameInfo"])
      player_criteria <- PlayerCriteria.from_json(data["criteria"])
    after
      %BuddyMatching.Players.Player{player | game_info: game_info, criteria: player_criteria}
    end
  end
end
