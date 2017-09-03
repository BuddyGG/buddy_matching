defmodule LolBuddy.PlayerMatchTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Players
  alias LolBuddy.Player

  test "two players match" do
    assert Players.match?(%Player{id: 1}, %Player{id: 2})
  end

  test "two players dont match" do
    refute Players.match?(%Player{id: 1}, %Player{id: 1})
  end
end