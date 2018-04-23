defmodule BuddyMatching.Players.Info do
  @moduledoc """
  Defines the behavior necessary to parse and use a game specific
  info structs for Players.
  """

  @doc "Function creating a given struct from a map of data, returned as a result tuple."
  @callback from_json(Map) :: {:ok, Struct} | {:error, String.t}
end
