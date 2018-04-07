defmodule FortniteApi do
  @moduledoc """
  This module handles all interaction with Fortnite's Unofficial API.
  It is expected to be accessed through 'RiotApi.fetch_user_info/2'.
  """

  require OK
  alias Poison.Parser

  @base_url "www.example.com"

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok, Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, body}
  end

  defp parse_json(data) do
    data
    |> HTTPoison.get()
    |> handle_json
  end

  defp fetch_user(name, region) do
    key_launcher = Application.fetch_env!(:fortnite_api, :fortnite_api_key_launcher)
    key_client = Application.fetch_env!(:fortnite_api, :fortnite_api_key_client)

    (@base_url <> "/some_url/#{name}?api_key=#{key}")
    |> parse_json
  end

  @doc """
  Return a map containing the given player's stats.

  If summoner does not exist for region returns {:error, error}

  ## Examples
    iex> RiotApi.fetch_user_info("Lethly", :pc)
    {:ok, %{}}
  """
  def fetch_user_info(name, platform) do
  end
end
