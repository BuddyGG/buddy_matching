defmodule LolBuddyRiotApi.ChampionsTest do
  require LolBuddy.RiotApi.Champions
  use ExUnit.Case, async: true

  test "thresh id" do
    id = 412
    name  = LolBuddy.RiotApi.Champions.find_by_id(id).name
    assert name == "Thresh"
  end

  test "vayne id" do
    id = 67
    name  = LolBuddy.RiotApi.Champions.find_by_id(id).name
    assert name == "Vayne"
  end

  test "ornn id" do
    id = 516
    name  = LolBuddy.RiotApi.Champions.find_by_id(id).name
    assert name == "Ornn"
  end

  test "tahm kench id" do
    id = 223
    name  = LolBuddy.RiotApi.Champions.find_by_id(id).name
    assert name == "Tahm Kench"
  end

  test "kog'maw id" do
    id = 96
    name  = LolBuddy.RiotApi.Champions.find_by_id(id).name
    assert name == "Kog'Maw"
  end
end
