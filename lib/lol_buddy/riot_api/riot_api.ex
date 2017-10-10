defmodule LolBuddy.RiotApi.Api do
  require OK
  alias LolBuddy.RiotApi.Regions
  alias LolBuddy.RiotApi.Positions
  alias LolBuddy.RiotApi.Champions
  import OK, only: ["~>>": 2]

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok ,Poison.Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, body}
  end

  defp parse_json(data) do
    data
    |> HTTPoison.get
    |> handle_json
  end

  defp fetch_summoner(name, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key)
    Regions.endpoint(region) <> "/lol/summoner/v3/summoners/by-name/#{name}?api_key=#{key}"
    |> parse_json
  end

  @doc """
  Returns a id and icon_id from a summoner name for a region.

  Returns {:ok, {id, icon_id}}

  ## Examples
      iex> LolBuddy.RiotApi.Api.summoner_ids("Lethly", :euw)
      {:ok, {22267137, 512}}
  """
  def summoner_ids(name, region) do
    OK.for do
      %{"id" => id, "profileIconId" => icon_id} <- fetch_summoner(name, region)
    after
      {id, icon_id}
    end
  end

  defp fetch_leagues(id, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key)
    Regions.endpoint(region) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{key}"
    |> parse_json
  end

  defp deromanize(rank) do
    case rank do
      "I"   -> 1
      "II"  -> 2
      "III" -> 3
      "IV"  -> 4
      "V"   -> 5
    end
  end

  @doc """
  Returns a list of maps, with each map containing info for each league.
  If a summoner is placed in multiple queues, the list will hold multiple maps.

  Returns {:ok, [%{type: "queuetype", tier: "tier", rank: rank"}]}

  ## Examples (one queue)
      iex> LolBuddy.RiotApi.Api.leagues(22267137, :euw)
      {:ok, [{type: "RANKED_SOLO_5x5", tier: "GOLD", rank: 1}]}
  """
  def leagues(id, region) do
    extract = fn(x) -> %{type: x["queueType"], tier: x["tier"],
       rank: deromanize(x["rank"])} end
    fetch_leagues(id, region)
    ~>> Enum.map(extract)
    |>  OK.success
  end

  defp name_from_id(id), do: Champions.find_by_id(id).name

  defp fetch_champions(id, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key)
    Regions.endpoint(region) <> "/lol/champion-mastery/v3/champion-masteries/by-summoner/#{id}?api_key=#{key}"
    |> parse_json
  end

  @doc """
  Returns a id and icon_id from a summoner name for a region.

  Returns {:ok, ["champion1", "champion2", "champion3"]}

  ## Examples
      iex> LolBuddy.RiotApi.Api.champions(22267137, :euw)
      {:ok, ["Vayne", "Caitlyn", "Ezreal"]}
  """
  def champions(id, region) do
    fetch_champions(id, region)
    ~>> Enum.take(3)
    |>  Enum.map(fn map -> Map.get(map,"championId") end)
    |>  Enum.map(fn id -> name_from_id(id) end)
    |>  OK.success
  end

  @doc """
  Return a map containing the given summoner's
  name, region, icon_id, champions, leagues and positions.

  If summoner does not exist for region returns {:error, error}

  ## Examples
    iex> LolBuddy.RiotApi.Api.fetch_summoner_info("Lethly", :euw)
    {:ok,
      %{champions: ["Vayne", "Caitlyn", "Ezreal"], icon_id: 512,
      leagues: [%{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"}],
      name: "Lethly", positions: [:marksman], region: :euw}}
  """
  def fetch_summoner_info(name, region) do
    OK.for do
      {id, icon_id} <- summoner_ids(name, region)
      champions <- champions(id, region)
      leagues <- leagues(id, region)
    after
      positions = Positions.positions(champions)
      %{name: name,
        region: region,
        icon_id: icon_id,
        champions: champions,
        leagues: leagues,
        positions: positions}
    end
  end
end
