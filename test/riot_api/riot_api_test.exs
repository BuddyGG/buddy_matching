defmodule LolBuddyRiotApi.ApiTest do
  require LolBuddy.RiotApi.Api
  use ExUnit.Case, async: true

  test "correct champions are extracted from matches" do
    matches =
      [%{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 18, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 18, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 27, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches)
    assert Enum.member?(most_played, "Jax")
    assert Enum.member?(most_played, "Sona")
    assert Enum.member?(most_played, "Tristana")
    assert Enum.count(most_played) == 3
  end

  test "draws still return at most 3 champions" do
    matches =
      [%{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 18, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 27, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches)
    assert Enum.count(most_played) == 3
  end

  test "less than 3 champions in matches still finds most played" do
    matches =
      [%{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches)
    assert Enum.member?(most_played, "Jax")
    assert Enum.count(most_played) == 1
  end
end
