defmodule BuddyMatching.Players.Criteria.LolCriteria do
  @moduledoc """
  Struct definining the possible criterias with which Players can
  filter their matches.
  """
  alias BuddyMatching.Players.Info.LolInfo
  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  @position_limit 5

  defstruct positions: []

  @doc """
  Parses the checkbox format the frontend uses for criteria
  into the criteria struct used in the backend.
  """
  def from_json(data) do
    cond do
      map_size(data["positions"]) > @position_limit ->
        {:error, "Too many positions in criteria"}

      true ->
        {:ok,
         %BuddyMatching.Players.Criteria.LolCriteria{
           positions: LolInfo.positions_from_json(data["positions"])
         }}
    end
  end
end
