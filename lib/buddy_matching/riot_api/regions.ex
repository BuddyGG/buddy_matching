defmodule BuddyMatching.RiotApi.Regions do
  @moduledoc """
  Contains the the list of rigions as well as the addresses for all of their endpoints.
  These can be found here:
  https://developer.riotgames.com/regional-endpoints.html
  """
  @type region ::
          :br
          | :eune
          | :euw
          | :jp
          | :kr
          | :lan
          | :las
          | :na
          | :oce
          | :tr
          | :ru
          | :pbe
  @regions %{
    br: "https://br1.api.riotgames.com",
    eune: "https://eun1.api.riotgames.com",
    euw: "https://euw1.api.riotgames.com",
    jp: "https://jp1.api.riotgames.com",
    kr: "https://kr.api.riotgames.com",
    lan: "https://la1.api.riotgames.com",
    las: "https://la2.api.riotgames.com",
    na: "https://na1.api.riotgames.com",
    oce: "https://oc1.api.riotgames.com",
    tr: "https://tr1.api.riotgames.com",
    ru: "https://ru.api.riotgames.com",
    pbe: "https://pbe1.api.riotgames.com"
  }

  def endpoint(region), do: @regions[region]
end
