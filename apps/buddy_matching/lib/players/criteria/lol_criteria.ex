defmodule BuddyMatching.Players.Criteria.LolCriteria do
  @moduledoc """
  Struct definining the possible criterias with which
  Lol Players can filter their matches.

  Implements `FromJsonBehaviour`.
  """
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  @position_limit 5

  defstruct positions: []

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in for lol players in the backend.

  Returns `%{:ok, %LolCriteria{}}` || `{:error, reason}`.
  """
  def from_json(data) do
    if map_size(data["positions"]) > @position_limit do
      {:error, "Too many positions in criteria"}
    else
      {:ok,
       %BuddyMatching.Players.Criteria.LolCriteria{
         positions: LolInfo.positions_from_json(data["positions"])
       }}
    end
  end
end
