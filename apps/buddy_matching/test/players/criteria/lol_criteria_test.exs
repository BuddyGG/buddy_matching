defmodule BuddyMatching.Criteria.LolCriteriaTest do
  use ExUnit.Case, async: true
  alias BuddyMatching.Players.Criteria.LolCriteria

  @criteria ~s({
    "positions":{
        "top":true,
        "jungle":true,
        "mid":true,
        "marksman":true,
        "support":true
     },
     "ageGroups":{
        "interval1":true,
        "interval2":true,
        "interval3":true
     },
     "voiceChat":{
        "YES":true,
        "NO":true
     },
     "ignoreLanguage": false
  })

  test "entire criteria is correctly parsed from json" do
    expected_criteria = %LolCriteria{
      positions: [:jungle, :marksman, :mid, :support, :top],
      age_groups: ["interval1", "interval2", "interval3"],
      voice: [false, true]
    }

    data = Poison.Parser.parse!(@criteria)
    assert {:ok, expected_criteria} == LolCriteria.from_json(data)
  end

  test "test voice_chat criteria are parsed correctly" do
    input = %{"YES" => true, "NO" => false}
    expected_voice = [true]
    assert expected_voice == LolCriteria.voice_from_json(input)
  end

  test "test age_groups are parsed correctly" do
    input = %{"interval1" => true, "interval2" => false, "interval3" => false}
    expected_age_groups = ["interval1"]
    assert expected_age_groups == LolCriteria.age_groups_from_json(input)
  end

  test "too many positions is invalid" do
    data = Poison.Parser.parse!(@criteria)
    bad_data = Map.update!(data, "positions", &Map.put(&1, "AFK", true))
    assert {:error, "Too many positions in criteria"} == LolCriteria.from_json(bad_data)
  end

  test "too many age groups is invalid" do
    data = Poison.Parser.parse!(@criteria)
    bad_data = Map.update!(data, "ageGroups", &Map.put(&1, "interval4", true))

    assert {:error, "Too many age groups in criteria"} == LolCriteria.from_json(bad_data)
  end

  test "too many voice chat values is invalid" do
    data = Poison.Parser.parse!(@criteria)
    bad_data = Map.update!(data, "voiceChat", &Map.put(&1, "MAYBE", true))

    assert {:error, "Too many values for voice chat in criteria"} ==
             LolCriteria.from_json(bad_data)
  end
end
