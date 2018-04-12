defmodule FortniteApi.Stats do
  @moduledoc """
  This module is responsible for interpreting and converting
  the stats as they are returned from the Fortnite API.
  """

  @solo "p2"
  @duo "p10"
  @squad "p9"

  def format_stats(stats) do
    stats
    |> Enum.map(&{Map.get(&1, "name"), Map.get(&1, "value")})
    |> Enum.into(%{})
  end

  # Expects the given stats to be formatted
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
      "gamesPlayed" => games_duo,
      "gamesWon" => wins_duo,
      "totalGamesPlayed" => total_games,
      "totalGamesWon" => total_wins,
      "top1finishes" => wins_duo,
      "top3finishes" => top3_duo,
      "top5finishes" => top5_duo,
      "killDeathRatio" => kdr_duo
    }
  end
end
