defmodule BuddyMatching.Info.FortniteInfoTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Info.FortniteInfo
  # alias BuddyMatching.Players.Criteria.FortniteCriteria

  @info_json ~s({
    "platform": "pc"
  })

  @info_struct %FortniteInfo{
    platform: :pc
  }

  test "entire fortniteinfo is correctly parsed from json" do
    data = Poison.Parser.parse!(@info_json)
    assert {:ok, @info_struct} == FortniteInfo.from_json(data)
  end

  test "parsing fortniteinfo with invalid platform returns an error" do
    data = Poison.Parser.parse!(@info_json)
    invalid_data = put_in(data["platform"], "gibberish")

    assert {:error, "Platform should be one of [\"pc\", \"ps4\", \"xbox\"]"} ==
             FortniteInfo.from_json(invalid_data)
  end
end
