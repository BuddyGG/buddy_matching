defmodule LolBuddy.AuthTest do
  use ExUnit.Case, async: true
  alias LolBuddy.Auth

  test "should generate session id" do
    assert is_binary(Auth.generate_session_id())
  end

  test "should generate session token from session id" do
    id = Auth.generate_session_id()
    assert is_binary(Auth.generate_session_token(id))
  end

  test "valid session token should match session id" do
    id = Auth.generate_session_id()
    token = Auth.generate_session_token(id)
    assert Auth.verify_session(id, token)
  end

  test "session token should NOT match other session id" do
    id = Auth.generate_session_id()
    id2 = Auth.generate_session_id()
    token = Auth.generate_session_token(id)
    refute Auth.verify_session(id2, token)
  end

  test "invalid session token should NOT match session id" do
    id = Auth.generate_session_id()
    token = "daiodffoiasjdf89e4u8923hiuiklwkd-02i109u"
    refute Auth.verify_session(id, token)
  end
end
