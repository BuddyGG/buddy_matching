defmodule LolBuddyWeb.PlayersChannelTest do
  use LolBuddyWeb.ChannelCase
  alias LolBuddyWeb.PlayersChannel
  alias LolBuddy.Players.Player
  setup do
    {:ok, _, socket} =
      socket("", %{})
      |> subscribe_and_join(PlayersChannel, "players:0", %{})
    {:ok, socket: socket}
  end

  #TODO - players need to have a region
  @tag :pending
  test "returns other matching players when joining channel and broadcast self as new player" do
    socket()
    |> join(PlayersChannel, "players:1", %{})
    
    #assert player 1 got player 0
    assert_push "new_players", %{players: [%Player{id: 0}]}
    #assert that player 0 got player 1
    assert_broadcast "new_player", %Player{id: 1}
  end
   
end
