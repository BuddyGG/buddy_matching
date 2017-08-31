defmodule LolBuddyRiotApi.PositionsTest do
  require LolBuddy.RiotApi.Positions
  use ExUnit.Case, async: true

  test "3 marksmen return marksman only position" do
    champs = ["Vayne", "Ezreal", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert positions == [:marksman]
  end

  test "combination of mid and marksmen" do
    champs = ["Viktor", "Ezreal", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert positions == [:marksman, :mid]
  end

  test "test that 3 equal weights still return just 2" do
    champs = ["Viktor", "Kled", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert Enum.count(positions) == 2
  end

end
