defmodule BuddyMatchingWeb.HealthController do
  use BuddyMatchingWeb, :controller
  action_fallback(BuddyMatchingWeb.FallbackController)

  def check(conn, _) do
    json(conn, "ok")
  end
end
