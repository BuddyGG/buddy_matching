defmodule BuddyMatching.Players.FortniteInfo do
  @moduledoc """
  Struct with leauge of legends game info
  """

  alias BuddyMatching.Players.Info
  @behaviour Info

  defstruct platform: nil

  def from_json(data) do
    %BuddyMatching.Players.FortniteInfo{}
  end
end
