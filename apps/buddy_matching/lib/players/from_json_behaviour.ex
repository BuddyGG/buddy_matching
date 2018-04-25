defmodule BuddyMatching.Players.FromJsonBehaviour do
  @moduledoc """
  Defines the behavior necessary for parsing a struct from a
  map, returning the struct in a result tuple. This is used for
  parsing Players, Criteria and GameInfo.
  """

  @doc "Function creating a given struct from a map of data, returned as a result tuple."
  @callback from_json(Map) :: {:ok, Struct} | {:error, String.t()}
end
