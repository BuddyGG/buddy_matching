defmodule LolBuddy.RiotApi.Regions do
  @type region :: :br | :eune | :euw | :jp | :kr | :lan | :las | :na | :oce | :tr | :ru | :pbe

  def endpoint(:br) do
    "https://br1.api.riotgames.com"
  end
  def endpoint(:eune) do
    "https://eun1.api.riotgames.com"
  end
  def endpoint(:euw) do
    "https://euw1.api.riotgames.com"
  end
  def endpoint(:jp) do
    "https://jp1.api.riotgames.com"
  end
  def endpoint(:kr) do
    "https://kr.api.riotgames.com"
  end
  def endpoint(:lan) do
    "https://la1.api.riotgames.com"
  end
  def endpoint(:las) do
    "https://la2.api.riotgames.com"
  end
  def endpoint(:na) do
    "https://na1.api.riotgames.com"
  end
  def endpoint(:oce) do
    "https://oc1.api.riotgames.com"
  end
  def endpoint(:tr) do
    "https://tr1.api.riotgames.com"
  end
  def endpoint(:ru) do
    "https://ru.api.riotgames.com"
  end
  def endpoint(:pbe) do
    "https://pbe1.api.riotgames.com"
  end
end
