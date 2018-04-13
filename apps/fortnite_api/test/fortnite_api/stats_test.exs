defmodule FortniteApi.StatsTest do
  alias FortniteApi.Stats
  use ExUnit.Case, async: true

  # @solo "p2"
  @duo "p10"
  # @squad "p9"

  @fortnite_stats [
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
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p10",
      "ownerType" => 1,
      "value" => 5,
      "window" => "alltime"
    },
    %{
      "name" => "br_score_pc_m0_p2",
      "ownerType" => 1,
      "value" => 678,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p2",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p9",
      "ownerType" => 1,
      "value" => 1_521_842_991,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1_521_834_802,
      "window" => "alltime"
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p2",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p9",
      "ownerType" => 1,
      "value" => 14,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop1_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_matchesplayed_pc_m0_p9",
      "ownerType" => 1,
      "value" => 20,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop12_pc_m0_p10",
      "ownerType" => 1,
      "value" => 2,
      "window" => "alltime"
    },
    %{
      "name" => "br_lastmodified_pc_m0_p10",
      "ownerType" => 1,
      "value" => 1_521_986_670,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop10_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop25_pc_m0_p2",
      "ownerType" => 1,
      "value" => 1,
      "window" => "alltime"
    },
    %{
      "name" => "br_kills_pc_m0_p10",
      "ownerType" => 1,
      "value" => 6,
      "window" => "alltime"
    },
    %{
      "name" => "br_placetop6_pc_m0_p9",
      "ownerType" => 1,
      "value" => 3,
      "window" => "alltime"
    }
  ]

  test "format_stats/1 formats correctly" do
    expected_output = %{
      "br_kills_pc_m0_p10" => 6,
      "br_kills_pc_m0_p2" => 2,
      "br_kills_pc_m0_p9" => 14,
      "br_lastmodified_pc_m0_p10" => 1_521_986_670,
      "br_lastmodified_pc_m0_p2" => 1_521_834_802,
      "br_lastmodified_pc_m0_p9" => 1_521_842_991,
      "br_matchesplayed_pc_m0_p10" => 5,
      "br_matchesplayed_pc_m0_p2" => 2,
      "br_matchesplayed_pc_m0_p9" => 20,
      "br_placetop10_pc_m0_p2" => 1,
      "br_placetop12_pc_m0_p10" => 2,
      "br_placetop1_pc_m0_p2" => 1,
      "br_placetop25_pc_m0_p2" => 1,
      "br_placetop6_pc_m0_p9" => 3,
      "br_score_pc_m0_p10" => 703,
      "br_score_pc_m0_p2" => 678,
      "br_score_pc_m0_p9" => 2669
    }

    actual_output = Stats.format_stats(@fortnite_stats)
    assert expected_output == actual_output
  end

  test "get_stats_for_queue/3 fetches correct results" do
    stats = Stats.format_stats(@fortnite_stats)
    {games, kills, wins, top3, top5} = Stats.get_stats_for_queue(stats, "pc", @duo)

    assert 5 == games
    assert 6 == kills
    assert 0 == wins
    assert 0 == top3
    assert 0 == top5
  end

  test "get_duo_stats/2 correctly extracts and  formats duo pc stats from all stats" do
    expected_output = %{
      "duo" => %{
        "gamesPlayed" => 5,
        "gamesWon" => 0,
        "killDeathRatio" => 1.2,
        "top1finishes" => 0,
        "top3finishes" => 0,
        "top5finishes" => 0
      },
      "total" => %{"totalGamesPlayed" => 27, "totalGamesWon" => 1}
    }

    actual_output = Stats.get_duo_stats(@fortnite_stats, "pc")
    assert expected_output == actual_output
  end
end
