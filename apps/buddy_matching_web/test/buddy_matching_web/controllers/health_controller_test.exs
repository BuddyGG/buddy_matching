defmodule BuddyMatching.HealthControllerTest do
  use BuddyMatchingWeb.ConnCase

  test "health controller return ok if alive" do
    conn = build_conn()

    res =
      conn
      |> get(health_path(conn, :check))
      |> json_response(200)

    assert res == "ok"
  end
end
