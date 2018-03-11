defmodule BuddyMatching.AuthControllerTest do
  use BuddyMatchingWeb.ConnCase
  alias BuddyMatchingWeb.Auth

  test "generate session id and token" do
    conn = build_conn()

    response =
      conn
      |> get(auth_path(conn, :show))
      |> json_response(200)

    assert is_binary(response["session_id"])
    assert is_binary(response["session_token"])

    assert Auth.verify_session(response["session_id"], response["session_token"])
  end
end
