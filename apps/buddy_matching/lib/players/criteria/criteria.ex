defmodule BuddyMatching.Players.Criteria do
  @moduledoc """
  Defines the behavior necessary to parse and use a game specific
  criteria structs for Players.
  """

  @doc "Function creating a given struct from a map of data."
  @callback from_json(Map) :: {:ok, Struct} | {:error, String.t}
end
