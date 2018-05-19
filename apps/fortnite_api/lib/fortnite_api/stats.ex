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

  ## Examples:

    iex> format_stats([%{"name" => "br_score_pc_m0_p10", "value" => 703}])
    %{"br_score_pc_m0_p10" => 703}

  """
  def format_stats(stats) do
    Enum.reduce(stats, %{}, fn x, acc -> Map.put(acc, x["name"], x["value"]) end)
  end

  defp get_shared_queue_stats(stats, queue, platform) do
    games = Map.get(stats, "br_matchesplayed_#{platform}_m0_#{queue}", 0)
    wins = Map.get(stats, "br_placetop1_#{platform}_m0_#{queue}", 0)
    kills = Map.get(stats, "br_kills_#{platform}_m0_#{queue}", 0)
    deaths = games - wins
    kdr = if deaths != 0, do: kills / deaths, else: 0
    %{"gamesPlayed" => games, "gamesWon" => wins, "killDeathRatio" => kdr}
  end

  defp get_solo_stats(stats, platform) do
    top10 = Map.get(stats, "br_placetop10_#{platform}_m0_#{@solo}", 0)
    top25 = Map.get(stats, "br_placetop25_#{platform}_m0_#{@solo}", 0)
    stats
    |> get_shared_queue_stats(@solo, platform)
    |> Map.put("top10finishes", top10)
    |> Map.put("top25finishes", top25)
  end

  defp get_duo_stats(stats, platform) do
    top5 = Map.get(stats, "br_placetop5_#{platform}_m0_#{@duo}", 0)
    top12 = Map.get(stats, "br_placetop12_#{platform}_m0_#{@duo}", 0)
    stats
    |> get_shared_queue_stats(@duo, platform)
    |> Map.put("top5finishes", top5)
    |> Map.put("top12finishes", top12)
  end

  defp get_squad_stats(stats, platform) do
    top3 = Map.get(stats, "br_placetop3_#{platform}_m0_#{@squad}", 0)
    top6 = Map.get(stats, "br_placetop6_#{platform}_m0_#{@squad}", 0)
    stats
    |> get_shared_queue_stats(@squad, platform)
    |> Map.put("top3finishes", top3)
    |> Map.put("top6finishes", top6)
  end

  @doc """
  Extracts and format stats for the all brackets from the given
  stats returned by Fortnite API and the given platform.

  ## Examples:

    iex> stats = [
      %{
        "name" => "br_score_pc_m0_p10",
        "ownerType" => 1,
        "value" => 703,
        "window" => "alltime"
      },
      %{
        "name" => "br_score_pc_m0_p9",
        "ownerType" => 1,
        "value" => 2669,
        "window" => "alltime"
      }...]
    iex> Stats.get_duo_stats(stats, "pc")
    %{"solo" => %{
      "gamesPlayed" => 5,
      "gamesWon" => 0,
      "killDeathRatio" => 1.2,
      "top1finishes" => 0,
      "top3finishes" => 0,
      "top5finishes" => 0
    }
      "duo" => %{..},
      "squad" => %{..},
      "total" => %{"totalGamesPlayed" => 27, "totalGamesWon" => 1}
    }

  """
  def get_stats(stats, platform) do
    stats = format_stats(stats)
    solo_stats = get_solo_stats(stats, platform)
    duo_stats = get_duo_stats(stats, platform)
    squad_stats = get_squad_stats(stats, platform)
    total_games = solo_stats["gamesPlayed"] + duo_stats["gamesPlayed"] + squad_stats["gamesWon"]
    total_wins = solo_stats["gamesWon"] + duo_stats["gamesWon"] + squad_stats["gamesWon"]
    %{
      "total" => %{
        "totalGamesPlayed" => total_games,
        "totalGamesWon" => total_wins
      },
      "solo" => solo_stats,
      "duo" => duo_stats,
      "squad" => squad_stats
    }
  end
end
