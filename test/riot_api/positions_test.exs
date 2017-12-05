defmodule LolBuddyRiotApi.PositionsTest do
  require LolBuddy.RiotApi.Positions
  use ExUnit.Case, async: true

  test "3 marksmen return marksman only position" do
    champs = ["Vayne", "Xayah", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert positions == [:marksman]
  end

  test "combination of mid and marksmen" do
    champs = ["Viktor", "Vayne", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert Enum.member?(positions, :marksman)
    assert Enum.member?(positions, :mid)
  end

  test "test that 3 equal weights still return just 2" do
    champs = ["Viktor", "Kled", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert Enum.count(positions) == 2
  end

  test "3 roles covered just the two most likely" do
    champs = ["Kennen", "Kayle", "Vayne"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    IO.inspect(positions)
    assert Enum.count(positions) == 2
    assert Enum.member?(positions, :marksman)
    assert Enum.member?(positions, :top)
  end

end
