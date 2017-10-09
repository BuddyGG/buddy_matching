defmodule LolBuddyWeb.PlayersChannelTest do
  use LolBuddyWeb.ChannelCase
  alias LolBuddyWeb.PlayersChannel
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria
  alias Poison
  
  @broad_criteria  %Criteria{positions: [:top, :jungle, :mid, :marksman, :support],
      voice: false, age_groups: [1,2,3]}

  @narrow_criteria  %Criteria{positions: [:marksman], voice: false, age_groups: [1]}

  @diamond1  %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}

  @base_player1  %Player{id: 1, name: "Lethly", region: :euw, voice: false,
  languages: ["danish"], age_group: 1, positions: [:marksman],
  leagues: [@diamond1], champions: ["Vayne", "Ezreal", "Caitlyn"],
  criteria: @broad_criteria, comment: "Never dies on Vayne"}

  @base_player2  %Player{id: 2, name: "hansp", region: :euw, voice: false,
  languages: ["danish", "english"], age_group: 1, positions: [:top],
  leagues: [@diamond1], champions: ["Cho'Gath", "Renekton", "Riven"],
  criteria: @narrow_criteria, comment: "Apparently I play Riven"}

  
  test "returns other matching players when joining channel and broadcast self as new player" do
    {:ok, _, player1} = socket("user:1", %{})
      |> subscribe_and_join(PlayersChannel, "players:#{@base_player1.id}", @base_player1)
   
    #assert player 1 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: "players:1",
      event: "new_players",
      payload: %{players: []}}
   
    {:ok, _, player2} =socket("user:2", %{})
    |> join(PlayersChannel, "players:#{@base_player2.id}", @base_player2)

    :ok = close(player1)
    :ok = close(player2)
    
    #assert player 2 got player 1
    assert_receive %Phoenix.Socket.Message{
      topic: "players:2",
      event: "new_players",
      payload: %{players: [@base_player1]}}

    #assert that player 1 got player 2
    assert_receive %Phoenix.Socket.Broadcast{
      topic: "players:1",
      event: "new_player",
      payload: @base_player2}

  end

  test "can join channel with valid json payload" do
    player =  ~s({
    "champions":[
       "Vayne",
       "Caitlyn",
       "Ezreal"
    ],
    "icon_id":512,
    "leagues":[
       {
          "type":"RANKED_SOLO_5x5",
          "tier":"GOLD",
          "rank":"I"
       }
    ],
    "positions":[
       "marksman"
    ],
    "name":"Lethly",
    "region":"euw",
    "userInfo":{
    "id" : 1,
       "selectedRoles":{
          "top":true,
          "jun":true,
          "mid":false,
          "adc":false,
          "sup":false
       },
       "languages":[
          "DA"
       ],
       "voicechat":true,
       "agegroup":"20-29",
       "comment":"test"
    }
 })

    data = Poison.Parser.parse!(player)
    {:ok, _, player1} = socket("user:1", %{})
      |> subscribe_and_join(PlayersChannel, "players:1", %{"payload" => data})
      
    :ok = close(player1)
    
      assert_receive %Phoenix.Socket.Message{
      topic: "players:1",
      event: "new_players",
      payload: %{players: []}}
  end

  test "player can request to match with an other player" do
    {:ok, _, player1} = socket("test2", %{})
    |> subscribe_and_join(PlayersChannel, "players:#{@base_player1.id}", @base_player1)
   
    {:ok, _, player2} = socket("test2", %{})
    |> join(PlayersChannel, "players:#{@base_player2.id}", @base_player2)
    
    player1 
    |> push("request_match", %{"player" => @base_player2})

    :ok = close(player1)
    :ok = close(player2)
    
    #Both players should recive the match request
    assert_receive %Phoenix.Socket.Message{
      topic: "players:1",
      event: "match_requested",
      payload: @base_player2
    }

    assert_receive %Phoenix.Socket.Message{
      topic: "players:2",
      event: "match_requested",
      payload: @base_player1
    }
      
  end
  
  test "player can respond to match request" do
    {:ok, _, player1} = socket("test2", %{})
    |> subscribe_and_join(PlayersChannel, "players:#{@base_player1.id}", @base_player1)
   
    {:ok, _, player2} = socket("test2", %{})
    |> join(PlayersChannel, "players:#{@base_player2.id}", @base_player2)
    
    player1 
    |> push("respond_to_request", %{"id" => @base_player2.id, "response" => "accepted"})
    
    :ok = close(player1)
    :ok = close(player2)
    
    #Both players should recive the request response from player1
    assert_receive %Phoenix.Socket.Message{
      topic: "players:1",
      event: "request_response",
      payload: %{response: "accepted"}
    }

    assert_receive %Phoenix.Socket.Message{
      topic: "players:2",
      event: "request_response",
      payload: %{response: "accepted"}
    }
      
  end
  
end
