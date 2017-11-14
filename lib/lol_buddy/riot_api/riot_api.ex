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
  Returns name, id and account_id and icon_id of a summoner for a region.

  Returns {:ok, {name, id, account_id, icon_id}}

  ## Examples
      iex> LolBuddy.RiotApi.Api.summoner_info("lethly", :euw)
      {:ok, {"Lethly", 22267137, 26102926, 512}}
  """
  def summoner_info(name, region) do
    OK.for do
      %{"name" => name, 
        "id" => id, 
        "accountId" => account_id,
        "profileIconId" => icon_id} <- fetch_summoner(name, region)
    after
      {name, id, account_id, icon_id}
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
  Returns the 3 champions with highest mastery score for a given
  summoner_id and region.

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
  Returns the names of the 3 most played champions based on a list of maps 
  containing data of matches in league of legends.

  ### Examples
  iex> matches =
    [%{"champion" => 24, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 24, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 37, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 37, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 18, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 18, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"},
     %{"champion" => 27, "lane" => "BOTTOM", 440, "role" => "DUO_SUPPORT"}]
  iex> LolBuddy.RiotApi.Api.extract_most_played(matches)
  ["Jax", "Sona", "Tristana"]
  """
  def extract_most_played(matches) do
    matches
    |> Enum.map(fn map -> Map.get(map, "champion") end)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end) # count occurences
    |> Enum.into([])
    |> Enum.sort(&(elem(&1,1) >= elem(&2,1)))
    |> Enum.take(3)
    |> Enum.map(fn {champ_id, _} -> name_from_id(champ_id) end)
  end

  defp fetch_recent_champions(id, region) do
    key = Application.fetch_env!(:lol_buddy, :riot_api_key)
    Regions.endpoint(region) <> "/lol/match/v3/matchlists/by-account/#{id}/recent?api_key=#{key}"
    |> parse_json
  end

  @doc """
  Returns the three most played champions based on the last 20 maches played
  for the given account_id on the given region.

  Returns {:ok, ["champion1", "champion2", "champion3"]}

  ## Examples
      iex> LolBuddy.RiotApi.Api.recent_champions(26102926, :euw)
      {:ok, ["Vayne", "Varus", "Xayah"]}
  """
  def recent_champions(account_id, region) do
    fetch_recent_champions(account_id, region)
    ~>> Map.get("matches")
    |>  extract_most_played()
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
      {summoner_name, id, account_id, icon_id} <- summoner_info(name, region)
      champions <- recent_champions(account_id, region)
      #champions <- champions(id, region)
      leagues <- leagues(id, region)
    after
      positions = Positions.positions(champions)
      %{name: summoner_name,
        region: region,
        icon_id: icon_id,
        champions: champions,
        leagues: leagues,
        positions: positions}
    end
  end
end
