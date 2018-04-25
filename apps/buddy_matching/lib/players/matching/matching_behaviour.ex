defmodule BuddyMatching.Players.MatchingBehaviour do
  @moduledoc """
  Defines the behavior necessary for implementing player matching.
  """

  @doc "Function taking 2 structs and returning whether they are a match"
  @callback match?(Struct, Struct) :: boolean
end
