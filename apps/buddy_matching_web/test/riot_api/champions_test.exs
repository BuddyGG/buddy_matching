defmodule BuddyMatchingRiotApi.ChampionsTest do
  require BuddyMatching.RiotApi.Champions
  use ExUnit.Case, async: true

  test "thresh id" do
    id = 412
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Thresh"
  end

  test "vayne id" do
    id = 67
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Vayne"
  end

  test "ornn id" do
    id = 516
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Ornn"
  end

  test "tahm kench id" do
    id = 223
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Tahm Kench"
  end

  test "kog'maw id" do
    id = 96
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Kog'Maw"
  end

  test "kai'sa id" do
    id = 145
    name = BuddyMatching.RiotApi.Champions.find_by_id(id).name
    assert name == "Kai'Sa"
  end
end
