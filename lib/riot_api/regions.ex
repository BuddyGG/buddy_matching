defmodule LolBuddy.RiotApi.Regions do
  @type region :: :br | :eune | :euw | :kr | :lan | :las | :na | :oce | :pbe | :ru | :tru

  def endpoint(:br) do
    "https://br.api.pvp.net"
  end
  def endpoint(:eune) do
    "https://eune.api.pvp.net"
  end
  def endpoint(:euw) do
    "https://euw.api.pvp.net"
  end
  def endpoint(:kr) do
    "https://kr.api.pvp.net"
  end
  def endpoint(:lan) do
    "https://lan.api.pvp.net"
  end
  def endpoint(:las) do
    "https://las.api.pvp.net"
  end
  def endpoint(:na) do
    "https://na.api.pvp.net"
  end
  def endpoint(:oce) do
    "https://oce.api.pvp.net"
  end
  def endpoint(:pbe) do
    "https://pbe.api.pvp.net"
  end
  def endpoint(:ru) do
    "https://RU.api.pvp.net"
  end
  def endpoint(:tr) do
    "https://tr.api.pvp.net"
  end

end
