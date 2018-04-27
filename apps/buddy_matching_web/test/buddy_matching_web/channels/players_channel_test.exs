defmodule BuddyMatchingWeb.PlayersChannelTest do
  use BuddyMatchingWeb.ChannelCase
  alias BuddyMatchingWeb.PlayersChannel
  alias BuddyMatching.Players.Player
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.Criteria.PlayerCriteria
  alias BuddyMatching.Players.Criteria.LolCriteria
  alias BuddyMatchingWeb.PlayerSocket
  alias BuddyMatchingWeb.Auth
  alias Poison

  @initial_matches_event "initial_matches"
  @new_match_event "new_match"
  @unmatch_event "remove_player"
  @request_event "match_requested"
  @request_response_event "request_response"
  @already_signed_up_event "already_signed_up"

  @player_broad_criteria %PlayerCriteria{
    voice: [false, true],
    age_groups: ["interval1", "interval2", "interval3"],
    ignore_language: true
  }

  @lol_broad_criteria %LolCriteria{
    positions: [:marksman, :top, :jungle, :top, :support]
  }
  @broad_criteria_payload %{
    "gameCriteria" => %{
      "positions" => %{
        "top" => true,
        "jungle" => true,
        "mid" => true,
        "marksman" => true,
        "support" => true
      }
    },
    "playerCriteria" => %{
      "ageGroups" => %{"interval1" => true, "interval2" => true, "interval3" => true},
      "voiceChat" => %{"YES" => true, "NO" => true},
      "ignoreLanguage" => true
    }
  }

  @lol_narrow_criteria %LolCriteria{positions: [:marksman]}

  @narrow_criteria_payload %{
    "gameCriteria" => %{
      "positions" => %{
        "top" => false,
        "jungle" => false,
        "mid" => false,
        "marksman" => true,
        "support" => false
      }
    },
    "playerCriteria" => %{
      "ageGroups" => %{"interval1" => true, "interval2" => false, "interval3" => false},
      "voiceChat" => %{"YES" => false, "NO" => true},
      "ignoreLanguage" => false
    }
  }

  @diamond1 %{type: "RANKED_SOLO_5x5", tier: "DIAMOND", rank: 1}

  @base_player1 %Player{
    name: "Lethly",
    id: "1",
    game: :lol,
    age_group: "interval1",
    languages: ["danish"],
    voice: [false],
    comment: "Great player",
    criteria: @player_broad_criteria,
    game_info: %LolInfo{
      icon_id: 512,
      region: :euw,
      game_criteria: @lol_broad_criteria,
      leagues: @diamond1,
      positions: [:marksman],
      champions: ["Vayne", "Caitlyn", "Ezreal"]
    }
  }

  @base_player2 %Player{
    name: "hansp",
    id: "2",
    game: :lol,
    age_group: "interval2",
    languages: ["danish", "english"],
    voice: [false],
    comment: "Apparently I play Riven",
    criteria: @player_broad_criteria,
    game_info: %LolInfo{
      icon_id: 512,
      region: :euw,
      game_criteria: @lol_narrow_criteria,
      leagues: @diamond1,
      positions: [:top],
      champions: ["Cho'Gath", "Renekton", "Riven"]
    }
  }

  def generate_player(id) do
    ~s({
    "name": "Lethly",
    "id": "#{id}",
    "game": "lol",
    "voiceChat": [
      true
    ],
    "ageGroup": "interval2",
    "comment": "test",
    "languages": [
      "DA",
      "KO",
      "EN"
    ],
    "criteria": {
      "ageGroups": {
        "interval1": true,
        "interval2": true,
        "interval3": true
      },
      "voiceChat": {
        "YES": true,
        "NO": true
      },
      "ignoreLanguage": false
    },
    "gameInfo": {
      "iconId": 512,
      "region": "euw",
      "champions": [
        "Vayne",
        "Caitlyn",
        "Ezreal"
      ],
      "leagues": {
        "type": "RANKED_SOLO_5x5",
        "tier": "GOLD",
        "rank": 1
      },
      "selectedRoles": {
        "top": true,
        "jungle": true,
        "mid": false,
        "marksman": false,
        "support": false
      },
      "gameCriteria": {
        "positions": {
          "top": true,
          "jungle": true,
          "mid": false,
          "marksman": false,
          "support": false
        }
      }
    }
  })
  end

  def parse_criteria_payload(payload) do
    {:ok, player_criteria} = PlayerCriteria.from_json(payload["playerCriteria"])
    {:ok, game_criteria} = LolCriteria.from_json(payload["gameCriteria"])
    {player_criteria, game_criteria}
  end

  def update_player_criteria(player, player_criteria, game_criteria) do
    updated_player = %Player{player | criteria: player_criteria}
    put_in(updated_player.game_info.game_criteria, game_criteria)
  end

  # Setup a socket with an authorized player, returns the socket, the player and the proposed topic to join on
  def setup_socket(player) do
    session_id = Auth.generate_session_id()
    token = Auth.generate_session_token(session_id)
    {:ok, socket} = connect(PlayerSocket, %{"session_id" => session_id, "session_token" => token})
    {socket, %{player | id: session_id}, "players:#{session_id}"}
  end

  test "get_player_id works for both player struct and json map" do
    player_struct = %Player{id: 1}
    player_map = %{"id" => 1}

    assert 1 == PlayersChannel.get_player_id(player_struct)
    assert 1 == PlayersChannel.get_player_id(player_map)
  end

  test "parse_player_payload json map, both wrapped in payload and not" do
    player = Poison.Parser.parse!(generate_player(1))
    player_wrapped = %{"payload" => player}

    assert {:ok, %Player{}} = PlayersChannel.parse_player_payload(player)
    assert {:ok, %Player{}} = PlayersChannel.parse_player_payload(player_wrapped)
  end

  test "returns other matching players when joining channel and broadcast self as new player" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    :ok = close(channel1)
    :ok = close(channel2)

    # assert player 1 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: []}
    }

    # assert player 2 got player 1
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @initial_matches_event,
      payload: %{players: [^player1]}
    }

    # assert that player 1 got player 2
    assert_receive %Phoenix.Socket.Broadcast{
      topic: ^topic1,
      event: @new_match_event,
      payload: ^player2
    }
  end

  test "can join channel with valid json payload" do
    {socket, auth_player, topic} = setup_socket(%{id: 1})
    player = generate_player(auth_player.id)
    data = Poison.Parser.parse!(player)

    {:ok, _, channel} = socket |> subscribe_and_join(PlayersChannel, topic, data)
    :ok = close(channel)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic,
      event: @initial_matches_event,
      payload: %{players: []}
    }
  end

  test "can't join channel with invalid json payload" do
    {socket, auth_player, topic} = setup_socket(%{id: 1})
    player = generate_player(auth_player.id)
    data = Poison.Parser.parse!(player)
    data = Map.put(data, "name", "a_too_god_damn_long_name_my_good_friend")

    {:error, _} = socket |> subscribe_and_join(PlayersChannel, topic, data)
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

    # player2 should recive the request response from player1
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

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @new_match_event,
      payload: ^player2
    }

    :ok = close(channel1)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @unmatch_event,
      payload: ^player1
    }

    :ok = close(channel2)
  end

  test "send leave event to player 2 when player 1 crashes" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    # unlink to first to avoid test being killed as well
    Process.unlink(channel1.channel_pid)
    Process.exit(channel1.channel_pid, :kill)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @unmatch_event,
      payload: ^player1
    }

    :ok = close(channel2)
  end

  @tag :only
  test "update criteria returns updated match list" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    # assert player 1 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: []}
    }

    # assert player 2 got no one else
    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @initial_matches_event,
      payload: %{players: [^player1]}
    }

    # update player 1's criteria to a less strict one
    push(channel1, "update_criteria", @narrow_criteria_payload)

    {player_criteria, game_criteria} = parse_criteria_payload(@narrow_criteria_payload)
    narrow_player1 = update_player_criteria(player1, player_criteria, game_criteria)

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic1,
      event: @initial_matches_event,
      payload: %{players: []}
    }

    assert_receive %Phoenix.Socket.Message{
      topic: ^topic2,
      event: @unmatch_event,
      payload: ^narrow_player1
    }

    :ok = close(channel1)
    :ok = close(channel2)
  end

  test "update criteria sends error if criteria can't be parsed" do
    {socket1, player1, topic1} = setup_socket(@base_player1)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)

    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: []}
      },
      2000
    )

    bad_criteria_payload =
      put_in(@narrow_criteria_payload["playerCriteria"]["ageGroups"]["interval100"], true)

    push(channel1, "update_criteria", bad_criteria_payload)

    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: "bad criteria",
        payload: %{reason: "The given criteria payload could not be parsed"}
      },
      2000
    )

    :ok = close(channel1)
  end

  test "update criteria sends unmatch events when no longer matching" do
    {socket1, player1, topic1} = setup_socket(@base_player1)
    {socket2, player2, topic2} = setup_socket(@base_player2)

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    # assert player 1 got no one else
    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: []}
      },
      2000
    )

    # assert player 2 got no one else
    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic2,
        event: @initial_matches_event,
        payload: %{players: [^player1]}
      },
      2000
    )

    # assert player 1 got player2
    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @new_match_event,
        payload: ^player2
      },
      2000
    )

    # update player 1's criteria to a stricter version
    push(channel1, "update_criteria", @narrow_criteria_payload)

    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: []}
      },
      2000
    )

    {player_criteria, game_criteria} = parse_criteria_payload(@narrow_criteria_payload)
    narrow_player1 = update_player_criteria(player1, player_criteria, game_criteria)

    assert_receive(
      %Phoenix.Socket.Message{topic: ^topic2, event: @unmatch_event, payload: ^narrow_player1},
      2000
    )

    :ok = close(channel1)
    :ok = close(channel2)
  end

  test "update criteria sends unmatch events when no longer matching, and match event
  when matching again" do
    {socket1, player1, topic1} = setup_socket(@base_player1)

    {socket2, player2, topic2} =
      setup_socket(%Player{@base_player2 | criteria: @player_broad_criteria})

    {:ok, _, channel1} = socket1 |> subscribe_and_join(PlayersChannel, topic1, player1)
    {:ok, _, channel2} = socket2 |> subscribe_and_join(PlayersChannel, topic2, player2)

    # assert player 1 got no one else
    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: []}
      },
      2000
    )

    # assert player 2 got no one else
    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic2,
        event: @initial_matches_event,
        payload: %{players: [^player1]}
      },
      2000
    )

    # update player 1's criteria to a stricter version
    push(channel1, "update_criteria", @narrow_criteria_payload)

    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: []}
      },
      2000
    )

    {player_criteria, game_criteria} = parse_criteria_payload(@narrow_criteria_payload)
    narrow_player1 = update_player_criteria(player1, player_criteria, game_criteria)

    assert_receive(
      %Phoenix.Socket.Message{topic: ^topic2, event: @unmatch_event, payload: ^narrow_player1},
      2000
    )

    # update player 1's criteria to a stricter version
    push(channel1, "update_criteria", @broad_criteria_payload)

    assert_receive(
      %Phoenix.Socket.Message{
        topic: ^topic1,
        event: @initial_matches_event,
        payload: %{players: [^player2]}
      },
      2000
    )

    {player_criteria, game_criteria} = parse_criteria_payload(@broad_criteria_payload)
    broad_player1 = update_player_criteria(player1, player_criteria, game_criteria)

    assert_receive(
      %Phoenix.Socket.Message{topic: ^topic2, event: @new_match_event, payload: ^broad_player1},
      2000
    )

    :ok = close(channel1)
    :ok = close(channel2)
  end
end
