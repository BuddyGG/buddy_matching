defmodule LolBuddy.RiotApi.Api do
  alias LolBuddy.RiotApi.Regions, as: Region
  alias LolBuddy.RiotApi.Positions, as: Position
  alias LolBuddy.RiotApi.Champions

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok ,Poison.Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, body}
  end

  defp summoner_url(name, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key) 
    Region.endpoint(region) <> "/lol/summoner/v3/summoners/by-name/#{name}?api_key=#{key}"
  end

  def parse_json(data) do
    data
    |> HTTPoison.get
    |> handle_json
  end

  def summoner_id(name, region) do
    summoner_url(name, region) 
    |> parse_json
    |> case do
        {:ok, summoner} -> {:ok, summoner |> Map.get("id")}
        {:error, error} -> {:error, error}
    end
  end 

  # Returns a list of tuples with various queue ranking
  # Example for just one queue> [{"RANKED_SOLO_5x5", "GOLD", "I"}]
  defp leagues_extract(values) do
    extract = fn(x) -> %{type: x["queueType"], tier: x["tier"], rank: x["rank"]} end
    Enum.map(values, extract)
  end

  defp leagues_url(id, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key) 
    Region.endpoint(region) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{key}"
  end

  def leagues(name, region) do
    with {:ok, id} <- summoner_id(name, region),
         {:ok, league} <- leagues_url(id, region) |> parse_json()
    do
      league = league |> leagues_extract
      {:ok, league}
    else 
      {:error, error} -> {:error, error}
    end
  end 

  # TODO: Here we could choose the endpoint based on closest to our hostserver
  def name_from_id(id) do
    Champions.find_by_id(id).name
  end

  defp champions_url(id, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key) 
    Region.endpoint(region) <> "/lol/champion-mastery/v3/champion-masteries/by-summoner/#{id}?api_key=#{key}"
  end

  # Returns a list of 3 most played champions as tuples eg.
  # [{67, Vayne"}, {51, "Caitlyn"}, {81, "Ezreal"}]
  def champions(name, region) do
    with {:ok, id} <- summoner_id(name, region),
         {:ok, champions} <- champions_url(id, region) |> parse_json()
    do
      champions = champions
      |> Enum.take(3)
      |> Enum.map(fn map -> Map.get(map,"championId") end)
      |> Enum.map(fn id -> %{id: id, name: name_from_id(id)} end)

      {:ok, champions}
    else
      {:error, error} -> {:error, error}
    end
  end

  # Returns a map containing name, region, champions and positions
  # for the given summoner in the given region
  def get_summoner_info(name, region) do 
    with {:ok, champions} <- champions(name, region),
         {:ok, leagues} <- leagues(name, region)
    do 
      positions = champions |> Enum.map(fn (x) -> x.name end) |> Position.positions()
      data = %{name: name,
      region: region,
      champions: champions,
      leagues: leagues,
      positions: positions}

      {:ok, data}
    else 
      {:error, error} -> {:error, error}
    end
  end
end
