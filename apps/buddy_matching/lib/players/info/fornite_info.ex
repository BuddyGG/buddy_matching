defmodule BuddyMatching.Players.Info.FortniteInfo do
  @moduledoc """
  Struct with Fortnite game info
  """

  alias BuddyMatching.Players.FromJsonBehaviour
  @behaviour FromJsonBehaviour

  defstruct platform: nil

  def from_json(_data) do
    {:ok, %BuddyMatching.Players.Info.FortniteInfo{}}
  end
end
