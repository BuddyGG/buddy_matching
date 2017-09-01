defmodule LolBuddyWeb.PlayersChannelTest do
  use LolBuddyWeb.ChannelCase

  alias LolBuddyWeb.PlayersChannel

  setup do
    {:ok, _, socket} =
      socket("player_socket", %{})
      |> subscribe_and_join(PlayersChannel, "players:lobby", %{"cookie_id" => 12})
  end

  test "new players are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "new_player", %{"some" => "data"}
    assert_push "new_player", %{"some" => "data"}
  end
   
  test "unauthenticated users cannot join" do
    error = socket()
      |> join(AuthorizedChannel, "authorized:lobby")

   assert {:error, %{reason: "unauthorized"}} = error
end
end
