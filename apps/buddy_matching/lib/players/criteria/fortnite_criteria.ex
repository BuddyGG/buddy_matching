defmodule BuddyMatching.Players.Criteria.FortniteCriteria do
  @moduledoc """
  Struct definining the possible criterias with which Fortnite
  Players can filter their matches.

  Implements `FromJsonBehaviour`.
  """
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  defstruct min_games_played: 0

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in the backend.

  Returns `{:ok, %LolInfo{}}` || `{:error, reason}`
  """
  def from_json(data) do
    {:ok,
     %BuddyMatching.Players.Criteria.FortniteCriteria{
       min_games_played: data["minGamesPlayed"]
     }}
  end
end
