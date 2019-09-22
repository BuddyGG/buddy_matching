defmodule FortniteApi.StatsTest do
  alias FortniteApi.Stats
  use ExUnit.Case, async: true

  setup_all do
    stats =
      "test/mock_json/stats.json"
      |> File.read!()
      |> Poison.decode!()

    [stats: stats]
  end

  test "format_stats/1 formats correctly", context do
    stats = context[:stats]

    expected_output = %{
      "br_kills_pc_m0_p10" => 20_129,
      "br_kills_pc_m0_p2" => 26_746,
      "br_kills_pc_m0_p9" => 10_133,
      "br_lastmodified_pc_m0_p10" => 1_526_704_368,
      "br_lastmodified_pc_m0_p2" => 1_526_660_886,
      "br_lastmodified_pc_m0_p9" => 1_526_719_560,
      "br_matchesplayed_pc_m0_p10" => 2769,
      "br_matchesplayed_pc_m0_p2" => 3458,
      "br_matchesplayed_pc_m0_p9" => 1613,
      "br_placetop10_pc_m0_p2" => 1562,
      "br_placetop12_pc_m0_p10" => 1626,
      "br_placetop1_pc_m0_p2" => 1190,
      "br_placetop25_pc_m0_p2" => 1876,
      "br_placetop6_pc_m0_p9" => 553,
      "br_score_pc_m0_p10" => 1_190_306,
      "br_score_pc_m0_p2" => 1_142_038,
      "br_score_pc_m0_p9" => 447_601,
      "br_minutesplayed_pc_m0_p10" => 17_407,
      "br_minutesplayed_pc_m0_p2" => 24_386,
      "br_minutesplayed_pc_m0_p9" => 8298,
      "br_placetop1_pc_m0_p10" => 1181,
      "br_placetop1_pc_m0_p9" => 361,
      "br_placetop3_pc_m0_p9" => 457,
      "br_placetop5_pc_m0_p10" => 1386
    }

    actual_output = Stats.format_stats(stats)
    assert expected_output == actual_output
  end

  test "get_stats/2 correctly extracts and formats pc stats from all stats", context do
    stats = context[:stats]

    expected_output = %{
      "duo" => %{
        "gamesPlayed" => 2769,
        "gamesWon" => 1181,
        "killDeathRatio" => 12.675692695214106,
        "top12finishes" => 1626,
        "top5finishes" => 1386
      },
      "solo" => %{
        "gamesPlayed" => 3458,
        "gamesWon" => 1190,
        "killDeathRatio" => 11.792768959435627,
        "top10finishes" => 1562,
        "top25finishes" => 1876
      },
      "squad" => %{
        "gamesPlayed" => 1613,
        "gamesWon" => 361,
        "killDeathRatio" => 8.093450479233226,
        "top3finishes" => 457,
        "top6finishes" => 553
      },
      "total" => %{"totalGamesPlayed" => 6588, "totalGamesWon" => 2732}
    }

    actual_output = Stats.get_stats(stats, "pc")
    assert expected_output == actual_output
  end
end
