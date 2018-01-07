defmodule LolBuddyWeb.PlayersChannelTest do
  use LolBuddyWeb.ChannelCase
  alias LolBuddyWeb.PlayersChannel
  alias LolBuddy.Players.Player
  alias LolBuddy.Players.Criteria
  alias LolBuddyWeb.PlayerSocket
  alias Poison
  alias LolBuddy.Auth

  @initial_matches_event "initial_matches"
  @new_match_event "new_match"
  @unmatch_event "remove_player"
  @request_event "match_requested"
  @request_response_event "request_response"
  @already_signed_up_event "already_signed_up"

  @broad_criteria  %Criteria{positions: [:marksman, :top, :jungle, :top, :support],
      voice: [false], age_groups: ["interval1", "interval2", "interval3"]}

  @narrow_criteria  %Criteria{positions: [:marksman], voice: [false], age_groups: ["interval1"]}

  @diamond1  %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}

  @base_player1  %Player{ name: "Lethly", region: :euw, voice: false,
  languages: ["danish"], age_group: "interval1", positions: [:marksman],
  leagues: [@diamond1], champions: ["Vayne", "Ezreal", "Caitlyn"],
  criteria: @broad_criteria, comment: "Never dies on Vayne"}

  @narrow_player1  %Player{name: "Trolleren", region: :euw, voice: false,
  languages: ["danish"], age_group: "interval1", positions: [:marksman],
  leagues: [@diamond1], champions: ["Vayne", "Ezreal", "Caitlyn"],
  criteria: @narrow_criteria, comment: "Never dies on Vayne"}

  @base_player2  %Player{name: "hansp", region: :euw, voice: false,
  languages: ["danish", "english"], age_group: "interval3", positions: [:top],
  leagues: [@diamond1], champions: ["Cho'Gath", "Renekton", "Riven"],
  criteria: @narrow_criteria, comment: "Apparently I play Riven"}

  #Setup a socket with an authorized player, returns the socket, the player and the proposed topic to join on
  def setup_socket(player) do
    session_id = Auth.generate_session_id
    token = Auth.generate_session_token(session_id)
    {:ok, socket} = connect(PlayerSocket, %{"session_id" => session_id, "session_token" => token})
    {socket, %{player | id: session_id}, "players:#{session_id}"}
  end

  test "returns other matching players when joining channel and broadcast self as new player" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    :ok = close(channel1)
    :ok = close(channel2)

    #assert player 1 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: []}
    }

    #assert player 2 got player 1
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @initial_matches_event,
      payload: %{players: [^player1]}
    }

    #assert that player 1 got player 2
    assert_receive %Phoenix.Socket.Broadcast{
      topic: ^topic1,
      event: @new_match_event,
      payload: ^player2
    }

  end

  test "can join channel with valid json payload" do
    {socket, auth_player, topic} = setup_socket(%{id: 1})

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
      "criteria": {
        "positions":{
            "top":true,
            "jungle":true,
            "mid":true,
            "marksman":true,
            "support":true
         },
         "ageGroups":{
            "interval1":true,
            "interval2":true,
            "interval3":true
         },
         "voiceChat":{
            "YES":true,
            "NO":true
         }
      },
    "id" : "#{auth_player.id}",
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

    {:ok, _, channel} = socket |> subscribe_and_join(PlayersChannel, topic, data)
    :ok = close(channel)

    assert_receive %Phoenix.Socket.Message{
    topic: ^topic,
    event: @initial_matches_event,
    payload: %{players: []}}
  end

  test "player can request to match with an other player" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    push(channel1, "request_match", %{"player" => player2})

    :ok = close(channel1)
    :ok = close(channel2)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @request_event,
      payload: ^player1
    }
  end

  test "same player can't sign up twice" do
    # although they get different ids, these players will be recognized
    # as the same by the PlayerServer
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player1)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    :ok = close(channel1)
    :ok = close(channel2)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @already_signed_up_event,
      payload: _
    }
  end

  test "player can respond to match request" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    push(channel1, "respond_to_request", %{"id" => player2.id, "response" => "accepted"})

    :ok = close(channel1)
    :ok = close(channel2)

    #player2 should recive the request response from player1
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @request_response_event,
      payload: %{response: "accepted"}
    }
  end

  test "send leave event to player 2 when player 1 leaves" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    :ok = close(channel1)
    :ok = close(channel2)

    #assert that player got told that player 1 left
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @unmatch_event,
      payload: ^player1}
  end

  test "update criteria returns updated match list" do
    {socket1, player1, topic1} = setup_socket(@narrow_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)


    #assert player 1 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: []}}


    #assert player 2 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @initial_matches_event,
      payload: %{players: []}}

    broad_criteria =
      %{"positions" => %{"top" => true, "jungle" => true, "mid" => true,
        "marksman" => true, "support" => true},
        "ageGroups" => %{"interval1" => true, "interval2" => true, "interval3" => true},
        "voiceChat" => %{"YES" => true, "NO" => true}}

    # update player 1's criteria to a stricter version
    push(channel1, "update_criteria", broad_criteria)

    :ok = close(channel1)
    :ok = close(channel2)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: [^player2]}}

    broad_criteria_parsed = Criteria.from_json(broad_criteria)
    broad_player1 = %{player1 | criteria: broad_criteria_parsed}
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @new_match_event,
      payload: ^broad_player1}
  end
end
