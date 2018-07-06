defmodule BuddyMatching.Players.MatchingBehaviour do
  @moduledoc """
  Defines the behavior necessary for implementing player matching.
  All games are expected to have a game specific module implementing
  this behavior, used for matching Player's with the Game specific,
  game info.
  """

  @doc "Function taking 2 structs and returning whether they are a match"
  @callback match?(Struct, Struct) :: boolean
end
