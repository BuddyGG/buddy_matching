# Buddy Matching Web
This Phoenix app is the main app in the umbrella, from which the underlying matching logic
and API integrations are made accessible. For keeping track of open connections and potential
crashes [Presence](https://hexdocs.pm/phoenix/Phoenix.Presence.html) is used with an [additional GenServer](lib/buddy_matching_web/presence/leave_tracker.ex) responsible for monitoring the channel and removing Players who have left/crashed from their [PlayerServer](../buddy_matching/lib/player_server/player_server.ex).
