defmodule LolBuddyWeb.PlayersChannelTest do
  use LolBuddyWeb.ChannelCase
  alias LolBuddyWeb.PlayersChannel
  alias LolBuddy.Player
  setup do
    {:ok, _, socket} =
      socket("", %{})
      |> subscribe_and_join(PlayersChannel, "players:lobby", %{"cookie_id" => 0})
    
    {:ok, socket: socket}
  end

  test "new players are pushed to the client when matched", %{socket: socket} do
    broadcast_from! socket, "new_player", %Player{id: 1}
    assert_push "new_player", %Player{id: 1}
  end
  
  test "new players are not pushed to the client when they dont match", %{socket: socket} do
    broadcast_from! socket, "new_player", %Player{id: 0}
    refute_push "new_player", _
  end
   
   
  test "unauthenticated users cannot join" do
    error = socket()
      |> join(PlayersChannel, "players:lobby")

   assert {:error, %{reason: "unauthorized"}} = error
end
end
