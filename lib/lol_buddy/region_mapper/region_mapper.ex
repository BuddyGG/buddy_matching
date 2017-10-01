defmodule LolBuddy.RegionMapper do
  alias LolBuddy.Players.Player
  alias LolBuddy.PlayerServer

  @doc """
  Returns the input sorted as a tuple {high, low}
  If they are equal, league1 is returned as highest

  ## Examples
      iex> LolBuddy.RegionMapper.get_players(:euw)
        [%{id: 1, name: "Lethly", region: :euw},
         %{id: 2, name: "hansp", region: :euw}]
  """
  def get_players(region) do
    PlayerServer.read(region)
  end

  @doc """
  If a player with a realm of a PlayerServer we don't know is
  attempted to be added, we simply return and error.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> LolBuddy.RegionMapper.add_player(player)
        {:error, "Bad region"}
  """
  def add_player(%Player{region: nil}) do
    {:error, "Bad region"}
  end

  @doc """
  Adds the given player to a PlayerServer based
  on his region.

  ## Examples
      iex> player = %{id: 1, name: "Lethly", region: :non_existent_regoin}
      iex> LolBuddy.RegionMapper.add_player(player)
        :ok
  """
  def add_player(%Player{} = player) do
    PlayerServer.add(player.region, player)
  end
end
