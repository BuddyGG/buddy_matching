defmodule BuddyMatching.Players.Info.FortniteInfo do
  @moduledoc """
  Struct with Fortnite game info
  """

  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  defstruct game_criteria: nil, platform: nil

  def from_json(data) do
    {:ok,
     %BuddyMatching.Players.Info.FortniteInfo{
       platform: String.to_existing_atom(data["platform"])
     }}
  end
end
