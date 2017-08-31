defmodule LolBuddyRiotApi.PositionsTest do
  require LolBuddy.RiotApi.Positions
  use ExUnit.Case, async: true

  test "3 marksmen return marksman only position" do
    champs = ["Vayne", "Ezreal", "Caitlyn"]
    positions = LolBuddy.RiotApi.Positions.positions(champs)
    assert response == [:marksman]
  end

end
