defmodule LolBuddyRiotApi.ApiTest do
  require LolBuddy.RiotApi.Api
  use ExUnit.Case, async: true

  test "correct champions are extracted from matches" do
    matches =
      [%{"champion" => 24},
       %{"champion" => 24},
       %{"champion" => 37},
       %{"champion" => 37},
       %{"champion" => 18},
       %{"champion" => 18},
       %{"champion" => 27}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches, 3)
    assert Enum.member?(most_played, "Jax")
    assert Enum.member?(most_played, "Sona")
    assert Enum.member?(most_played, "Tristana")
    assert Enum.count(most_played) == 3
  end

  test "champion draws still return at most 3 champions" do
    matches =
      [%{"champion" => 24},
       %{"champion" => 37},
       %{"champion" => 18},
       %{"champion" => 27}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches, 3)
    assert Enum.count(most_played) == 3
  end

  test "less than 3 champions in matches still finds most played" do
    matches =
      [%{"champion" => 24},
       %{"champion" => 24},
       %{"champion" => 24}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_champions(matches, 3)
    assert Enum.member?(most_played, "Jax")
    assert Enum.count(most_played) == 1
  end

  test "correct role is extracted from a match, top" do
    match = %{"lane" => "TOP", "role" => "SOLO"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :top
  end

  test "correct role is extracted from a match, jungle" do
    match = %{"lane" => "JUNGLE", "role" => "NONE"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :jungle
  end

  test "correct role is extracted from a match, mid" do
    match = %{"lane" => "MID", "role" => "SOLO"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :mid
  end

  test "correct role is extracted from a match, marksman" do
    match = %{"champion" => 18, "lane" => "BOTTOM", "role" => "DUO_CARRY"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :marksman
  end

  test "correct role is extracted from a match, duo case" do
    match = %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :support
  end

  test "correct role is extracted from a match, support" do
    match = %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"}
    assert LolBuddy.RiotApi.Api.role_from_match(match) == :support
  end

  test "correct most played role is extracted from a match list, single role" do
    matches =
      [%{"lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"lane" => "BOTTOM", "role" => "DUO_SUPPORT"}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_role(matches, 2)
    assert Enum.count(most_played) == 1
    assert Enum.member?(most_played, :support)
  end

  test "correct most played role is extracted from a match list" do
    matches =
      [%{"champion" => 24, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 37, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 18, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
       %{"champion" => 27, "lane" => "BOTTOM", "role" => "DUO_SUPPORT"}]
    most_played = LolBuddy.RiotApi.Api.extract_most_played_role(matches, 2)
    assert Enum.count(most_played) == 1
    assert Enum.member?(most_played, :support)
  end


end
