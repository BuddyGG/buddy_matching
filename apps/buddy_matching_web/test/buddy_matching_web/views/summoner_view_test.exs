defmodule BuddyMatchingWeb.SummonerViewTest do
  use BuddyMatchingWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders summoner.json" do
    summoner = %{
      champions: ["Vayne", "Tristana", "Ezreal"],
      icon_id: 1407,
      leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
      name: "Lethly",
      positions: [:marksman, :mid],
      region: :euw
    }

    assert render(BuddyMatchingWeb.SummonerView, "show.json", summoner: summoner) == %{
             data: summoner
           }
  end
end
