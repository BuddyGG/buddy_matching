defmodule LolBuddy.AuthControllerTest do
    use LolBuddyWeb.ConnCase

    test "generate session id and token" do
      conn = build_conn()

      response = conn
      |> get(auth_path(conn, :show))
      |> json_response(200)
      
      assert is_binary(response["session_id"])
      assert is_binary(response["session_token"])

      {:ok, session_id} =  Phoenix.Token.verify(LolBuddyWeb.Endpoint, "session", response["session_token"])
      assert session_id == response["session_id"]
      
    end
  end