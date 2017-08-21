defmodule LolBuddy.RiotApi.Api do
  alias LolBuddy.RiotApi.Regions, as: Region
  @key "RGAPI-65ceef4e-1417-447d-8938-c2b50e2d31c5"

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    Poison.Parser.parse!(body)
  end

  defp handle_json({_, %{status_code: _, body: _}}) do
    IO.puts "Check if region or summoner name is wrong"
  end

  defp summoner_url(name, region) do
    Region.endpoint(region) <> "/lol/summoner/v3/summoners/by-name/#{name}?api_key=#{@key}"
  end

  def summoner_id(name, region) do
    summoner_url(name, region) 
    |> HTTPoison.get
    |> handle_json
    |> Map.get("id")
  end 

  # Returns a list of tuples with various queue ranking
  # Example for just one queue> [{"RANKED_SOLO_5x5", "GOLD", "I"}]
  defp leagues_extract(values) do
    extract = fn(x) -> {x["queueType"], x["tier"], x["rank"]} end
    Enum.map(values, extract)
  end

  defp leagues_url(id, region) do
    Region.endpoint(region) <> "/lol/league/v3/positions/by-summoner/#{id}?api_key=#{@key}"
  end

  def leagues(name, region) do
      summoner_id(name, region)
      |> leagues_url(region) 
      |> HTTPoison.get
      |> handle_json
      |> leagues_extract
  end 

  # TODO: Here we could choose the endpoint based on closest to our host
  def name_from_id(id, region) do
    Region.endpoint(region) <> "/lol/static-data/v3/champions/#{id}?api_key=#{@key}"
    |> IO.inspect
    |> HTTPoison.get
    |> handle_json
    |> Map.get("name")
  end

  defp champions_url(id, region) do
    Region.endpoint(region) <> "/lol/champion-mastery/v3/champion-masteries/by-summoner/#{id}?api_key=#{@key}"
  end

  # Returns a list of 3 most played champions as tuples eg.
  # [{67, Vayne"}, {51, "Caitlyn"}, {81, "Ezreal"}]
  def champions(name, region) do
    summoner_id(name, region)
    |> champions_url(region) 
    |> HTTPoison.get
    |> handle_json
    |> Enum.take(3)
    |> Enum.map(fn map -> Map.get(map,"championId") end)
    |> Enum.map(fn id -> {id, name_from_id(id, region)} end)
  end 

end
