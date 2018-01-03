defmodule LolBuddy.RiotApi.Positions do
  @moduledoc """
  Module for deducing positions from a list of champions.
  This is done through a manually maintained list of most likely played positions
  for each champion.
  """

  @always 3
  @mainly 2
  @rarely 1

  @positions %{"Aatrox" => [{:top, @mainly}, {:jungle, @rarely}],
                "Ahri" => [{:mid, @always}],
                "Akali" => [{:top, @mainly}, {:mid, @rarely}],
                "Alistar" => [{:support, @mainly}, {:jungle, @rarely}],
                "Amumu" => [{:jungle, @mainly}, {:top, @rarely}],
                "Anivia" => [{:mid, @always}],
                "Annie" => [{:mid, @mainly}, {:support, @rarely}],
                "Ashe" => [{:marksman, @always}],
                "Aurelion Sol" => [{:mid, @always}],
                "Azir" => [{:mid, @always}],
                "Bard" => [{:support, @always}],
                "Blitzcrank" => [{:support, @always}],
                "Brand" => [{:mid, @mainly}, {:support, @rarely}],
                "Braum" => [{:support, @always}],
                "Caitlyn" => [{:marksman, @always}],
                "Camille" => [{:top, @mainly}, {:mid, @rarely}],
                "Cassiopeia" => [{:mid, @always}],
                "Cho'Gath" => [{:top, @mainly}, {:jungle, @rarely}],
                "Corki" => [{:marksman, @mainly}, {:mid, @rarely}],
                "Darius" => [{:top, @always}],
                "Diana" => [{:mid, @mainly}, {:jungle, @rarely}],
                "Dr. Mundo" => [{:jungle, @mainly}, {:top, @rarely}],
                "Draven" => [{:marksman, @always}],
                "Ekko" => [{:mid, @mainly}, {:jungle, @rarely}],
                "Elise" => [{:jungle, @always}],
                "Evelynn" => [{:jungle, @always}],
                "Ezreal" => [{:marksman, @always}],
                "Fiddlesticks" => [{:jungle, @mainly}, {:support, @rarely}],
                "Fiora" => [{:top, @always}],
                "Fizz" => [{:mid, @mainly}, {:jungle, @rarely}],
                "Galio" => [{:top, @always}],
                "Gangplank" => [{:top, @always}],
                "Garen" => [{:top, @mainly}, {:jungle, @rarely}],
                "Gnar" => [{:top, @always}],
                "Gragas" => [{:jungle, @mainly}, {:top, @rarely}],
                "Graves" => [{:marksman, @mainly}, {:jungle, @rarely}],
                "Hecarim" => [{:jungle, @always}],
                "Heimerdinger" => [{:mid, @mainly}, {:top, @rarely}],
                "Illaoi" => [{:top, @always}],
                "Irelia" => [{:top, @mainly}, {:jungle, @rarely}],
                "Ivern" => [{:jungle, @always}],
                "Janna" => [{:support, @always}],
                "Jarvan" => [{:jungle, @always}],
                "Jax" => [{:top, @mainly}, {:jungle, @rarely}],
                "Jayce" => [{:mid, @mainly}, {:top, @mainly}],
                "Jhin" => [{:marksman, @always}],
                "Jinx" => [{:marksman, @always}],
                "Kalista" => [{:marksman, @always}],
                "Karma" => [{:support, @always}],
                "Karthus" => [{:mid, @always}],
                "Kassadin" => [{:mid, @always}],
                "Katarina" => [{:mid, @always}],
                "Kayle" => [{:mid, @mainly}, {:top, @rarely}],
                "Kayn" => [{:jungle, @mainly}, {:top, @rarely}],
                "Kennen" => [{:top, @mainly}, {:mid, @rarely}],
                "Kha'Zix" => [{:jungle, @always}],
                "Kindred" => [{:jungle, @always}],
                "Kled" => [{:top, @always}],
                "Kog'Maw" => [{:marksman, @always}],
                "LeBlanc" => [{:mid, @always}],
                "Lee Sin" => [{:jungle, @always}],
                "Leona" => [{:support, @always}],
                "Lissandra" => [{:mid, @mainly}, {:top, @rarely}],
                "Lucian" => [{:marksman, @always}],
                "Lulu" => [{:support, @always}],
                "Lux" => [{:mid, @always}],
                "Malphite" => [{:top, @always}],
                "Malzahar" => [{:mid, @always}],
                "Maokai" => [{:jungle, @always}],
                "Master Yi" => [{:jungle, @always}],
                "Miss Fortune" => [{:marksman, @always}],
                "Mordekaiser" => [{:top, @mainly}, {:mid, @rarely}],
                "Morgana" => [{:support, @mainly}, {:mid, @rarely}],
                "Nami" => [{:support, @always}],
                "Nasus" => [{:top, @always}],
                "Nautilus" => [{:jungle, @mainly}, {:support, @rarely}],
                "Nidalee" => [{:jungle, @mainly}, {:support, @rarely}],
                "Nocturne" => [{:jungle, @always}],
                "Nunu" => [{:jungle, @always}],
                "Olaf" => [{:jungle, @always}, {:top, @rarely}],
                "Orianna" => [{:mid, @always}],
                "Ornn" => [{:jungle, @mainly}, {:top, @rarely}],
                "Pantheon" => [{:jungle, @mainly}, {:top, @rarely}],
                "Poppy" => [{:top, @always}],
                "Quinn" => [{:marksman, @mainly}, {:top, @rarely}],
                "Rakan" => [{:support, @always}],
                "Rammus" => [{:jungle, @always}],
                "Rek'Sai" => [{:jungle, @always}],
                "Renekton" => [{:top, @always}],
                "Rengar" => [{:jungle, @mainly}, {:top, @rarely}],
                "Riven" => [{:top, @always}],
                "Rumble" => [{:top, @always}],
                "Ryze" => [{:mid, @always}],
                "Sejuani" => [{:jungle, @always}],
                "Shaco" => [{:jungle, @always}],
                "Shen" => [{:top, @always}],
                "Shyvana" => [{:jungle, @mainly}, {:top, @rarely}],
                "Singed" => [{:top, @always}],
                "Sion" => [{:top, @always}],
                "Sivir" => [{:marksman, @always}],
                "Skarner" => [{:jungle, @always}],
                "Sona" => [{:support, @always}],
                "Soraka" => [{:support, @always}],
                "Swain" => [{:mid, @mainly}, {:top, @rarely}],
                "Syndra" => [{:mid, @always}],
                "Tahm Kench" => [{:support, @always}],
                "Taliyah" => [{:mid, @always}],
                "Talon" => [{:mid, @mainly}, {:top, @rarely}],
                "Taric" => [{:support, @always}],
                "Teemo" => [{:top, @always}],
                "Thresh" => [{:support, @always}],
                "Tristana" => [{:marksman, @always}],
                "Trundle" => [{:top, @always}],
                "Tryndamere" => [{:top, @always}],
                "Twisted Fate" => [{:mid, @always}],
                "Twitch" => [{:marksman, @always}],
                "Udyr" => [{:jungle, @mainly}, {:top, @rarely}],
                "Urgot" => [{:marksman, @mainly}, {:top, @rarely}],
                "Varus" => [{:marksman, @always}],
                "Vayne" => [{:marksman, @always}],
                "Veigar" => [{:mid, @always}],
                "Vel'Koz" => [{:mid, @mainly}, {:support, @rarely}],
                "Vi" => [{:jungle, @always}],
                "Viktor" => [{:mid, @mainly}],
                "Vladimir" => [{:mid, @mainly}, {:top, @rarely}],
                "Volibear" => [{:jungle, @always}],
                "Warwick" => [{:jungle, @always}],
                "Wukong" => [{:top, @mainly}, {:jungle, @rarely}],
                "Xayah" => [{:marksman, @always}],
                "Xerath" => [{:mid, @always}],
                "Xin Xhao" => [{:jungle, @mainly}, {:top, @rarely}],
                "Yasuo" => [{:mid, @always}],
                "Yorick" => [{:top, @always}],
                "Zac" => [{:jungle, @always}],
                "Zed" => [{:mid, @always}],
                "Ziggs" => [{:mid, @always}],
                "Zilean" => [{:support, @mainly}, {:mid, @rarely}],
                "Zyra" => [{:support, @always}]}

  # Here, we expect a list of positions with their total weight.
  # We sort this on the weights, and set the threshold of
  # @always * 2 + @rarely as being weight needed for us to assume
  # that the player mains only this role.
  #
  # If no such weight is present, we take the first 2 positions
  # from the sorted list, and return this, without applying
  # any clever tricks in case of equal weights.
  #
  # Returns eg: `[:marksman, :mid]`
  #
  # Examples
  #
  #   iex> deduce_positions([{:marksman, 8}, {:mid, 1}])
  #   [:marksman]
  #
  defp deduce_positions(weights) do
    threshold = @always * 2 + @rarely
    weights = List.keysort(weights, 1) |> Enum.reverse
    case List.first(weights) do
      {pos, weight} when weight > threshold -> [pos]
      _ -> Enum.take(Keyword.keys(weights), 2)
    end
  end

  @doc """
  Based on a list of champion names, returns a list of either 1 or 2 roles
  that are most likely the roles associated with the given champions.

  ## Examples
      iex> champs = ["Vayne", "Xayah", "Caitlyn"]
      iex> LolBuddy.RiotApi.Positions.positions(champs)
      [:marksman]
  """
  # Expects a list of champion names, and returns a list of positions as atoms
  def positions(champions) do
    List.foldl(champions, [], fn(x, acc) ->
      Keyword.merge(acc, @positions[x], fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> deduce_positions
  end
end
