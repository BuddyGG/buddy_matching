defmodule LolBuddy.RiotApi.Positions do
  @always 3
  @mainly 2
  @rarely 1

  @positions %{ "Aatrox" => [{:top, @mainly}, {:jungle, @rarely}],
                "Ahri" => [{:mid, @always}],
                "Akali" => [{}],
                "Alistar" => [{:support, @mainly}, {:jungle, @rarely}, {:top, @rarely}],
                "Amumu" => [{:jungle, @mainly}, {:top, @rarely],
                "Anivia" => [{:mid, @always}],
                "Annie" => [{:mid, @mainly}, {:support, @rarely}],
                "Ashe" => [{:marksman, @always}],
                "Aurelion Sol" => [{:mid, @always}],
                "Azir" => [{:mid, @always}],
                "Bard" => [{:support, @always}],
                "Blitzcrank" => [{:support, @always}],
                "Brand" => [{:mid, @mostly}, {:support, @rarely}],
                "Braum" => [{:support, @always}],
                "Caitlyn" => [{:marksman, @always}],
                "Camille" => [{}],
                "Cassiopeia" => [{:mid, @always}],
                "Cho'Gath" => [{:top, @mostly}, {:jungle, @rarely],
                "Corki" => [{:marksman, @mostly}, {:mid, @rarely}],
                "Darius" => [{:top, @always}],
                "Diana" => [{:jungle, @mostly}, {:mid, @rarely}],
                "Dr. Mundo" => [{:jungle, @mostly}, {:top, @rarely}],
                "Draven" => [{{marksman: @always}],
                "Ekko" => [{:mid, @mostly}, {:jungle, @rarely}],
                "Elise" => [{:jungle, @always}],
                "Evelynn" => [{:jungle, @always}],
                "Ezreal" => [{:marksman, @always}],
                "Fiddlesticks" => [{:jungle, @mostly}, {:mid, @rarely}],
                "Fiora" => [{:top, @always}],
                "Fizz" => [{:mid, @mostly}, {:jungle, @rarely}],
                "Galio" => [{}],
                "Gangplank" => [{}],
                "Garen" => [{:top, @mostly}, {:jungle, @rarely}],
                "Gnar" => [{:top, @always}],
                "Gragas" => [{:jungle, @mostly}, {:top, @rarely}],
                "Graves" => [{:marksman, @mostly}, {:jungle, @rarely}],
                "Hecarim" => [{:jungle, @always}],
                "Heimerdinger" => [{:mid, @always],
                "Illaoi" => [{}],
                "Irelia" => [{:top, @mostly}, {:jungle, @rarely}],
                "Ivern" => [{:jungle, @always}],
                "Janna" => [{:support, @always}],
                "Jarvan" => [{:jungle, @always}],
                "Jax" => [{:top, @mostly}, {:jungle, @rarely}],
                "Jayce" => [{:mid, @mostly}, {:top, @mostly}],
                "Jhin" => [{:marksman, @always}}],
                "Jinx" => [{:marksman, @always}],
                "Kalista" => [{:marksman, @always}],
                "Karma" => [{:support, @always}],
                "Karthus" => [{:mid, @always}],
                "Kassadin" => [{:mid, @always}],
                "Katarina" => [{:mid, @always}],
                "Kayle" => [{:mid, @always}],
                "Kayn" => [{}],
                "Kennen" => [{:top, @mostly}, {:mid, @rarely}],
                "Kha'Zix" => [{:jungle, @always}],
                "Kindred" => [{:jungle, @always}],
                "Kled" => [{}],
                "Kog'Maw" => [{:marksman, @always}],
                "LeBlanc" => [{:mid, @always}],
                "Lee Sin" => [{:jungle, @always}],
                "Leona" => [{:support, @always}],
                "Lissandra" => [{}],
                "Lucian" => [{:marksman, @always}],
                "Lulu" => [{:support, @always}],
                "Lux" => [{:mid, @always}],
                "Malphite" => [{}],
                "Malzahar" => [{:mid, @always}],
                "Maokai" => [{:jungle, @always}],
                "Master Yi" => [{:jungle, @always}],
                "Miss Fortune" => [{:marksman, @always}],
                "Mordekaiser" => [{}],
                "Morgana" => [{:support, @mostly}, {:mid, @rarely}],
                "Nami" => [{:support, @always}],
                "Nasus" => [{:top, @always}],
                "Nautilus" => [{:jungle, @mostly}, {:support, @rarely}],
                "Nidalee" => [{:jungle, @mostly}, {:support, @rarely}],
                "Nocturne" => [{:jungle, @always}],
                "Nunu" => [{:jungle, @always}],
                "Olaf" => [{:jungle, @always}, {:top, @rarely}],
                "Orianna" => [{:mid, @always}],
                "Ornn" => [{}],
                "Pantheon" => [{:jungle, @mostly}, {:top, @rarely}],
                "Poppy" => [{:top, @always}],
                "Quinn" => [{:marksman, @mostly}, {:top, @rarely}],
                "Rakan" => [{:support, @always}],
                "Rammus" => [{:jungle, @always}],
                "Rek'Sai" => [{:jungle, @always}],
                "Renekton" => [{:top, @always}],
                "Rengar" => [{:jungle, @mostly}, {:top, @rarely}],
                "Riven" => [{:top, @always}],
                "Rumble" => [{:top, @always}],
                "Ryze" => [{:mid, @always}],
                "Sejuani" => [{:jungle, @always}],
                "Shaco" => [{:jungle, @always}],
                "Shen" => [{:top, @always}],
                "Shyvana" => [{:jungle, @mostly}, {:top, @rarely}],
                "Singed" => [{:top, @always}],
                "Sion" => [{:top, @always}],
                "Sivir" => [{:marksman, @always}],
                "Skarner" => [{:jungle, @always}],
                "Sona" => [{:support, @always}],
                "Soraka" => [{:support, @always}],
                "Swain" => [{:mid, @mostly}, {:top, @rarely}],
                "Syndra" => [{:mid, @always}],
                "Tahm Kench" => [{:support, @always}],
                "Taliyah" => [{:mid, @always}],
                "Talon" => [{:mid, @mostly}, {:top, @rarely}],
                "Taric" => [{:support, @always}],
                "Teemo" => [{:top, @always}],
                "Thresh" => [{:support, @always}],
                "Tristana" => [{:marksman, @always}],
                "Trundle" => [{:top, @always}],
                "Tryndamere" => [{:top, @always}],
                "Twisted Fate" => [{:mid, @always}],
                "Twitch" => [{:marksman, @always}],
                "Udyr" => [{:jungle, @mostly}, {:top, @rarely}],
                "Urgot" => [{:marksman, @mostly}, {:top, @rarely}],
                "Varus" => [{:marksman, @always}],
                "Vayne" => [{:marksman, @always}],
                "Veigar" => [{:mid, @always}],
                "Vel'Koz" => [{:support, @mostly}, {:mid, @rarely}],
                "Vi" => [{:jungle, @always}],
                "Viktor" => [{:mid, @mostly}],
                "Vladimir" => [{:mid, @mostly}, {:top, @rarely}],
                "Volibear" => [{:jungle, @always}],
                "Warwick" => [{:jungle, @always}],
                "Wukong" => [{:top, @mostly}, {:jungle, @rarely}],
                "Xayah" => [{:marksman, @always}],
                "Xerath" => [{:mid, @always}],
                "Xin Xhao" => [{:jungle, @mostly}, {:top, @rarely],
                "Yasuo" => [{:mid, @always}],
                "Yorick" => [{:top, @always}],
                "Zac" => [{:jungle, @always}],
                "Zed" => [{:mid, @always}],
                "Ziggs" => [{:mid, @always}],
                "Zilean" => [{:mid, @always}],
                "Zyra" => [{:support, @always}]
              }

end
