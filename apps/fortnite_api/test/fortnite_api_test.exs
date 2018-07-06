defmodule FortniteApi.Test do
  alias FortniteApi
  use ExUnit.Case, async: true

  test "validate platform pc" do
    assert {:ok, "pc"} = FortniteApi.validate_platform("PC")
    assert {:ok, "pc"} = FortniteApi.validate_platform("pc")
  end

  test "validate platform xb1" do
    assert {:ok, "xb1"} = FortniteApi.validate_platform("XB1")
    assert {:ok, "xb1"} = FortniteApi.validate_platform("xb1")
  end

  test "validate platform ps4" do
    assert {:ok, "ps4"} = FortniteApi.validate_platform("PS4")
    assert {:ok, "ps4"} = FortniteApi.validate_platform("ps4")
  end

  test "validate platform, invalid platforms" do
    assert {:error, _} = FortniteApi.validate_platform("wii")
    assert {:error, _} = FortniteApi.validate_platform("xb")
    assert {:error, _} = FortniteApi.validate_platform("PS")
  end
end
