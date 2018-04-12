defmodule FortniteApi.Stats do
  @moduledoc """
  This module is responsible for interpreting and converting
  the stats as they are returned from the Fortnite API.
  """

  @solo "p2"
  @duo "p10"
  @squad "p9"

  @doc """
  Formats the list of maps returned by Fornite's API
  as a Map of %{"stat_type" => "value}.

  Examples:
    iex> format_stats([%{"name" => "br_score_pc_m0_p10", "value" => 703}])
    %{"br_score_pc_m0_p10" => 703}
  """
  def format_stats(stats) do
    Enum.reduce(stats, %{}, fn x, acc -> Map.put(acc, x["name"], x["value"]) end)
  end

  # Expects the given stats to be formatted
  @doc """
  Extracts specific stats from a formatted stats map, a platform
  and a queue type and returns them as a tuple:

  Examples:
    iex> stats = %{"br_placetop1_p2_pc" => 1, "br_placetop3_p2" => 3...}
    iex> get_stats_for_queue(stats, "pc", "p2")
    {5, 10, 1, 3, 7}
  """
  def get_stats_for_queue(stats, platform, queue) do
    wins = Map.get(stats, "br_placetop1_#{platform}_m0_#{queue}", 0)
    top3 = Map.get(stats, "br_placetop3_#{platform}_m0_#{queue}", 0)
    top5 = Map.get(stats, "br_placetop5_#{platform}_m0_#{queue}", 0)
    games = Map.get(stats, "br_matchesplayed_#{platform}_m0_#{queue}", 0)
    kills = Map.get(stats, "br_kills_#{platform}_m0_#{queue}", 0)

    {games, kills, wins, top3, top5}
  end

  def get_duo_stats(stats, platform) do
    stats = format_stats(stats)

    {games_solo, _, wins_solo, _, _} = get_stats_for_queue(stats, platform, @solo)

    {games_duo, kills_duo, wins_duo, top3_duo, top5_duo} =
      get_stats_for_queue(stats, platform, @duo)

    {games_squad, _, wins_squad, _, _} = get_stats_for_queue(stats, platform, @squad)

    deaths_duo = games_duo - wins_duo
    kdr_duo = if deaths_duo != 0, do: kills_duo / deaths_duo, else: 0
    total_games = games_solo + games_duo + games_squad
    total_wins = wins_solo + wins_duo + wins_squad

    %{
      "total" => %{
        "totalGamesPlayed" => total_games,
        "totalGamesWon" => total_wins
      },
      "duo" => %{
        "gamesPlayed" => games_duo,
        "gamesWon" => wins_duo,
        "top1finishes" => wins_duo,
        "top3finishes" => top3_duo,
        "top5finishes" => top5_duo,
        "killDeathRatio" => kdr_duo
      }
    }
  end
end
