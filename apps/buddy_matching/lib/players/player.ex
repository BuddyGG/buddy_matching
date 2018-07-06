defmodule BuddyMatching.Players.Player do
  @moduledoc """
  Module representing a Player struct, including JSON parsing thereof.

  Implements `FromJsonBehaviour`.
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
  id        = > Unique identifier for the player. Used for channels.
  name      = > The Player's name.
  game      = > Atom representing  game of Player. :lol, :fortnite etc.
  voice     = > List of voice options. Can be list with, true, false or both.
  languages = > A list of the Player's spoken languages.
  age_group = > The given Player's age group.
  comment   = > Potential remarks from the Player.
  criteria  = > The Player's %PlayerCritera{}
  game_info = > The Player's game specific info. Eg. %LolInfo{}.
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

  # Sort alphabetically, but ensure that English is first if present.
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

  @doc """
  Map a parsed JSON of game_info to the corresponding game_info parser given a game.
  """
  def info_from_json(:fortnite, gameInfo), do: FortniteInfo.from_json(gameInfo)
  def info_from_json(:lol, gameInfo), do: LolInfo.from_json(gameInfo)

  @doc """
  Map a parsed JSON of criteria to the corresponding criteria parser given a game.
  """
  def game_criteria_from_json(:fortnite, criteria), do: FortniteCriteria.from_json(criteria)
  def game_criteria_from_json(:lol, criteria), do: LolCriteria.from_json(criteria)

  @doc """
  Parses an entire Player from JSON into the Player.
  This includes game specific parsing, which will be passed along to the
  responsible module based on the `:game` of the Player.
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
