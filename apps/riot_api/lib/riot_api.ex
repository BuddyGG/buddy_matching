defmodule RiotApi do
  @moduledoc """
  This module handles all interaction with Riot's Developer Api.
  It is expected to be accessed through 'RiotApi.fetch_summoner_info/2',
  although several other functions are public, primarily for the sake of testing.
  """

  require OK
  alias RiotApi.Regions
  alias RiotApi.Champions
  alias Poison.Parser

  # https://developer.riotgames.com/game-constants.html
  @solo "420"

  defp handle_json({:ok, %{status_code: 200, body: body}}), do: {:ok, Parser.parse!(body)}
  defp handle_json({_, %{status_code: _, body: body}}), do: {:error, body}

  @doc """
  Function for sending a sending a request to Riot's API.
  The given path will be prepended with the given region's endpoint
  and the API-key from the environment will be appended to the final url query.
  HTTPoison will retrieve the result and it will be returned parsed by Poison
  in a result tuple.

  ## Examples
    iex> RiotApi.request("/lol/summoner/v3/summoners/by-name/Lethly", :euw)
    {:ok %{"name" => "Lethly"...}}
  """
  def request(path, region) do
    key = Application.fetch_env!(:riot_api, :riot_api_key)
    separator = if String.contains?(path, "?"), do: "&", else: "?"

    region
    |> Regions.endpoint()
    |> Kernel.<>("#{path}#{separator}api_key=#{key}")
    |> HTTPoison.get()
    |> handle_json()
  end

  defp fetch_summoner(name, region) do
    "/lol/summoner/v3/summoners/by-name/#{name}"
    |> request(region)
  end

  # Fetches the last 20 matches of any queue type for given account id
  defp fetch_recent_matches(account_id, region) do
    "/lol/match/v3/matchlists/by-account/#{account_id}/recent"
    |> request(region)
  end

  defp fetch_matches_for_queue(account_id, queue, region) do
    "/lol/match/v3/matchlists/by-account/#{account_id}?queue=#{queue}&endIndex=1"
    |> request(region)
  end

  defp fetch_match(match_id, region) do
    "/lol/match/v3/matches/#{match_id}"
    |> request(region)
  end

  defp fetch_leagues(id, region) do
    "/lol/league/v3/positions/by-summoner/#{id}"
    |> request(region)
  end

  defp name_from_id(id), do: Champions.find_by_id(id).name

  defp deromanize(rank) do
    case rank do
      "I" -> 1
      "II" -> 2
      "III" -> 3
      "IV" -> 4
      "V" -> 5
    end
  end

  # Utility function mostly to ensure that Challengers and Masters don't get
  # rank 1, as Riot shows this internally despite there being no such thing.
  defp parse_league(leagueInfo) do
    tier = leagueInfo["tier"]

    rank =
      if tier == "CHALLENGER" || tier == "MASTER", do: nil, else: deromanize(leagueInfo["rank"])

    %{type: leagueInfo["queueType"], tier: tier, rank: rank}
  end

  @doc """
  Returns name, id and account_id and icon_id of a summoner for a region.

  Returns {:ok, {name, id, account_id, icon_id}}

  ## Examples
      iex> RiotApi.summoner_info("lethly", :euw)
      {:ok, {"Lethly", 22267137, 26102926, 512}}
  """
  def summoner_info(name, region) do
    OK.for do
      %{"name" => name, "id" => id, "accountId" => account_id, "profileIconId" => icon_id} <-
        fetch_summoner(name, region)
    after
      {name, id, account_id, icon_id}
    end
  end

  @doc """
  Generic function for extracting the most frequent occuring elements in a list.
  Counts each element, sorts in decending order and takes the first 'amount'.
  Returns it as a map of (key => occurences)

  ## Examples
    iex> RiotApi.extract_most_frequent([3,3,3,2,2,1], 2)
    [3 => 3,2 => 2]
  """
  def extract_most_frequent(matches, amount) do
    matches
    |> Enum.reduce(%{}, fn x, acc ->
      # count occurences
      Map.update(acc, x, 1, &(&1 + 1))
    end)
    |> Enum.into([])
    |> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))
    |> Enum.take(amount)
  end

  @doc """
  Returns a list of the names of the 3 most played champions based on a
  list of maps containing data of matches in league of legends.

  ### Examples
    iex> matches =
      [%{"champion" => 24},
       %{"champion" => 24},
       %{"champion" => 37},
       %{"champion" => 37},
       %{"champion" => 18},
       %{"champion" => 18},
       %{"champion" => 27}]
    iex> RiotApi.extract_most_played(matches)
    ["Jax", "Sona", "Tristana"]
  """
  def extract_most_played_champions(matches, amount \\ 3) do
    matches
    |> Enum.map(fn map -> Map.get(map, "champion") end)
    |> extract_most_frequent(amount)
    |> Enum.map(fn {champ_id, _} -> name_from_id(champ_id) end)
  end

  @doc """
  From a match, converts Riot's lane/role combination to an atom
  indicating the role. For bottom, the role is based on Riot's own deduction
  and can be either "DUO", "DUO_CARRY" or "DUO_SUPPORT". This can be expanded
  to look at specific champions for the ambiguous "DUO" case but currently just
  says "DUO_CARRY" = :marksman, and the other two cases = :support.

  ### Examples
    iex> RiotApi.Api.role_from_match(%{"lane" => "TOP", "role" => "SOLO"})
    :top
    iex> RiotApi.Api.role_from_match(%{"lane" => "BOTTOM", "role" => "DUO"})
    :support
  """
  def role_from_match(%{"lane" => lane, "role" => role}) do
    case lane do
      "TOP" -> :top
      "JUNGLE" -> :jungle
      "MID" -> :mid
      "BOTTOM" when role == "DUO_CARRY" -> :marksman
      _ -> :support
    end
  end

  @doc """
  Returns a list of 3 most played roles based on a list of maps
  containing data of matches in league of legends.

  ### Examples
  iex> matches =
    [%{"lane" => "TOP", "role" => "SOLO"},
     %{"lane" => "TOP", "role" => "SOLO"},
     %{"lane" => "MID", "role" => "SOLO"},
     %{"lane" => "MID", "role" => "SOLO"},
     %{"lane" => "JUNGLE", "role" => "NONE"},
     %{"lane" => "BOTTOM", "role" => "DUO_SUPPORT"},
     %{"lane" => "BOTTOM", "role" => "DUO_CARRY"}]
  iex> RiotApi.extract_most_played(matches)
  [:top, :mid]
  """
  def extract_most_played_roles(matches, amount \\ 2) do
    matches
    |> Enum.map(fn match -> role_from_match(match) end)
    |> extract_most_frequent(amount)
    |> Keyword.keys()
  end

  @doc """
  Returns the three most played champions and two most played roles based
  on the last 20 maches played for the given account_id on the given region.

  Returns {:ok, {["champion1", "champion2", "champion3"], [:marksman, :support]}}

  ## Examples
      iex> RiotApi.recent_champions(26102926, :euw)
        {:ok, {["Vayne", "Varus", "Sona"], [:marksman, :support]}}
  """
  def recent_champions_and_roles(account_id, region) do
    OK.for do
      %{"matches" => matches} <- fetch_recent_matches(account_id, region)
    after
      champions = extract_most_played_champions(matches)
      roles = extract_most_played_roles(matches)
      {champions, roles}
    end
  end

  @doc """
  Returns the last played solo queue match for the given
  account_id, if they have played one.

  ### Examples
  iex> RiotApi.fetch_last_solo_match(26102926, :euw)
    {:ok, %{"gameCreation" => 1515525992929, "gameDuration" => 1382...}}
  """
  def fetch_last_solo_match(account_id, region) do
    OK.for do
      %{"matches" => matches} <- fetch_matches_for_queue(account_id, @solo, region)
      first = List.first(matches)["gameId"]
      last_game <- fetch_match(first, region)
    after
      last_game
    end
  end

  # From an account_id and a match, we find the border
  # for the given account_id. Eg. "PLATINUM" or "UNRANKED",
  # indicating what rank they had in last season in this queue.
  defp last_season_tier_from_match(account_id, match) do
    participant_id =
      match["participantIdentities"]
      |> Enum.find(fn %{"player" => %{"currentAccountId" => id}} -> account_id == id end)
      |> Map.get("participantId")

    match["participants"]
    |> Enum.find(fn %{"participantId" => id} -> participant_id == id end)
    |> Map.get("highestAchievedSeasonTier")
  end

  # Fetches the last 20 matches of any queue type for given account id
  defp fetch_recent_matches(id, region) do
    key = Application.fetch_env!(:riot_api, :riot_api_key)

    (Regions.endpoint(region) <> "/lol/match/v3/matchlists/by-account/#{id}/recent?api_key=#{key}")
    |> parse_json
  end

  @doc """
  Estimates last season's highest tier in "RANKED_SOLO_5x5" for a given
  account ID.

  Returns {:ok, %{rank: nil, tier: "PLATINUM", type: "RANKED_SOLO_5x5"}}

  ## Examples
      iex> RiotApi.last_seasons_rank(26102926, :euw)
        {:ok, %{rank: 1, tier: "DIAMOND", type: "RANKED_SOLO_5x5"}}
  """
  def last_seasons_rank(account_id, region) do
    OK.for do
      match <- fetch_last_solo_match(account_id, region)
    after
      account_id
      |> last_season_tier_from_match(match)
      |> case do
        nil -> %{rank: nil, tier: "UNRANKED", type: "RANKED_SOLO_5x5"}
        tier -> %{rank: nil, tier: tier, type: "RANKED_SOLO_5x5"}
      end
    end
  end

  @doc """
  Returns a list of maps, with each map containing info for each league.
  If a summoner is placed in multiple queues, the list will hold multiple maps.

  Returns {:ok, [%{type: "queuetype", tier: "tier", rank: rank"}]}

  ## Examples
      iex> RiotApi.leagues(22267137, 26102926, :euw)
      {:ok, {type: "RANKED_SOLO_5x5", tier: "PLATINUM", rank: 1}}
  """
  def leagues(id, account_id, region) do
    OK.for do
      leagues <- fetch_leagues(id, region)
    after
      leagues
      |> Enum.find(fn %{"queueType" => type} -> type == "RANKED_SOLO_5x5" end)
      |> case do
        nil -> last_seasons_rank(account_id, region)
        info -> parse_league(info)
      end
    end
  end

  @doc """
  Return a map containing the given summoner's
  name, region, icon_id, champions, leagues and positions.

  If summoner does not exist for region returns {:error, error}

  ## Examples
    iex> RiotApi.fetch_summoner_info("Lethly", :euw)
    {:ok,
      %{champions: ["Vayne", "Caitlyn", "Ezreal"], icon_id: 512,
      leagues: %{rank: 1, tier: "GOLD", type: "RANKED_SOLO_5x5"},
      name: "Lethly", positions: [:marksman], region: :euw}}
  """
  def fetch_summoner_info(name, region) do
    OK.for do
      {summoner_name, id, account_id, icon_id} <- summoner_info(name, region)
      {champions, roles} <- recent_champions_and_roles(account_id, region)
      leagues <- leagues(id, account_id, region)
    after
      %{
        name: summoner_name,
        region: region,
        icon_id: icon_id,
        champions: champions,
        leagues: leagues,
        positions: roles
      }
    end
  end
end
