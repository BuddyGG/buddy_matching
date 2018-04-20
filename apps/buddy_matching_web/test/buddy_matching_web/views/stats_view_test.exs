defmodule BuddyMatchingWeb.StatsViewTest do
  use BuddyMatchingWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders stats.json" do
    stats = %{
      br: 1,
      eune: 2,
      euw: 3,
      jp: 4,
      kr: 5,
      lan: 6,
      las: 7,
      na: 8,
      oce: 9,
      tr: 10,
      ru: 11,
      pbe: 12
    }

    assert render(BuddyMatchingWeb.StatsView, "show.json", stats: stats) == %{
             players_online: stats
           }
  end
end
