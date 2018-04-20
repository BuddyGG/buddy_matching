defmodule BuddyMatchingWeb.FortniteViewTest do
  use BuddyMatchingWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders fortnite's stats.json" do
    stats = %{
      "username" => "Lethly",
      "platform" => "pc",
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

    assert render(BuddyMatchingWeb.FortniteView, "show.json", fortnite: stats) == %{data: stats}
  end
end
