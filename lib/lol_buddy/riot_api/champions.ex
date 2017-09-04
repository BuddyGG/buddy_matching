defmodule LolBuddy.RiotApi.Champions do

    
    @champions  [ %{
        "id": 24,
        "key": "Jax",
        "name": "Jax",
        "title": "Grandmaster at Arms"
    },
    %{
        "id": 37,
        "key": "Sona",
        "name": "Sona",
        "title": "Maven of the Strings"
    },
    %{
        "id": 18,
        "key": "Tristana",
        "name": "Tristana",
        "title": "the Yordle Gunner"
    },
    %{
        "id": 110,
        "key": "Varus",
        "name": "Varus",
        "title": "the Arrow of Retribution"
    },
    %{
        "id": 114,
        "key": "Fiora",
        "name": "Fiora",
        "title": "the Grand Duelist"
    },
    %{
        "id": 27,
        "key": "Singed",
        "name": "Singed",
        "title": "the Mad Chemist"
    },
    %{
        "id": 223,
        "key": "TahmKench",
        "name": "Tahm Kench",
        "title": "the River King"
    },
    %{
        "id": 7,
        "key": "Leblanc",
        "name": "LeBlanc",
        "title": "the Deceiver"
    },
    %{
        "id": 412,
        "key": "Thresh",
        "name": "Thresh",
        "title": "the Chain Warden"
    },
    %{
        "id": 43,
        "key": "Karma",
        "name": "Karma",
        "title": "the Enlightened One"
    },
    %{
        "id": 202,
        "key": "Jhin",
        "name": "Jhin",
        "title": "the Virtuoso"
    },
    %{
        "id": 68,
        "key": "Rumble",
        "name": "Rumble",
        "title": "the Mechanized Menace"
    },
    %{
        "id": 77,
        "key": "Udyr",
        "name": "Udyr",
        "title": "the Spirit Walker"
    },
    %{
        "id": 64,
        "key": "LeeSin",
        "name": "Lee Sin",
        "title": "the Blind Monk"
    },
    %{
        "id": 83,
        "key": "Yorick",
        "name": "Yorick",
        "title": "Shepherd of Souls"
    },
    %{
        "id": 516,
        "key": "Ornn",
        "name": "Ornn",
        "title": "The Fire below the Mountain"
    },
    %{
        "id": 141,
        "key": "Kayn",
        "name": "Kayn",
        "title": "the Shadow Reaper"
    },
    %{
        "id": 38,
        "key": "Kassadin",
        "name": "Kassadin",
        "title": "the Void Walker"
    },
    %{
        "id": 15,
        "key": "Sivir",
        "name": "Sivir",
        "title": "the Battle Mistress"
    },
    %{
        "id": 21,
        "key": "MissFortune",
        "name": "Miss Fortune",
        "title": "the Bounty Hunter"
    },
    %{
        "id": 119,
        "key": "Draven",
        "name": "Draven",
        "title": "the Glorious Executioner"
    },
    %{
        "id": 157,
        "key": "Yasuo",
        "name": "Yasuo",
        "title": "the Unforgiven"
    },
    %{
        "id": 10,
        "key": "Kayle",
        "name": "Kayle",
        "title": "The Judicator"
    },
    %{
        "id": 35,
        "key": "Shaco",
        "name": "Shaco",
        "title": "the Demon Jester"
    },
    %{
        "id": 58,
        "key": "Renekton",
        "name": "Renekton",
        "title": "the Butcher of the Sands"
    },
    %{
        "id": 120,
        "key": "Hecarim",
        "name": "Hecarim",
        "title": "the Shadow of War"
    },
    %{
        "id": 105,
        "key": "Fizz",
        "name": "Fizz",
        "title": "the Tidal Trickster"
    },
    %{
        "id": 96,
        "key": "KogMaw",
        "name": "Kog'Maw",
        "title": "the Mouth of the Abyss"
    },
    %{
        "id": 57,
        "key": "Maokai",
        "name": "Maokai",
        "title": "the Twisted Treant"
    },
    %{
        "id": 127,
        "key": "Lissandra",
        "name": "Lissandra",
        "title": "the Ice Witch"
    },
    %{
        "id": 222,
        "key": "Jinx",
        "name": "Jinx",
        "title": "the Loose Cannon"
    },
    %{
        "id": 6,
        "key": "Urgot",
        "name": "Urgot",
        "title": "the Dreadnought"
    },
    %{
        "id": 9,
        "key": "Fiddlesticks",
        "name": "Fiddlesticks",
        "title": "the Harbinger of Doom"
    },
    %{
        "id": 3,
        "key": "Galio",
        "name": "Galio",
        "title": "the Colossus"
    },
    %{
        "id": 80,
        "key": "Pantheon",
        "name": "Pantheon",
        "title": "the Artisan of War"
    },
    %{
        "id": 91,
        "key": "Talon",
        "name": "Talon",
        "title": "the Blade's Shadow"
    },
    %{
        "id": 41,
        "key": "Gangplank",
        "name": "Gangplank",
        "title": "the Saltwater Scourge"
    },
    %{
        "id": 81,
        "key": "Ezreal",
        "name": "Ezreal",
        "title": "the Prodigal Explorer"
    },
    %{
        "id": 150,
        "key": "Gnar",
        "name": "Gnar",
        "title": "the Missing Link"
    },
    %{
        "id": 17,
        "key": "Teemo",
        "name": "Teemo",
        "title": "the Swift Scout"
    },
    %{
        "id": 1,
        "key": "Annie",
        "name": "Annie",
        "title": "the Dark Child"
    },
    %{
        "id": 82,
        "key": "Mordekaiser",
        "name": "Mordekaiser",
        "title": "the Iron Revenant"
    },
    %{
        "id": 268,
        "key": "Azir",
        "name": "Azir",
        "title": "the Emperor of the Sands"
    },
    %{
        "id": 85,
        "key": "Kennen",
        "name": "Kennen",
        "title": "the Heart of the Tempest"
    },
    %{
        "id": 92,
        "key": "Riven",
        "name": "Riven",
        "title": "the Exile"
    },
    %{
        "id": 31,
        "key": "Chogath",
        "name": "Cho'Gath",
        "title": "the Terror of the Void"
    },
    %{
        "id": 266,
        "key": "Aatrox",
        "name": "Aatrox",
        "title": "the Darkin Blade"
    },
    %{
        "id": 78,
        "key": "Poppy",
        "name": "Poppy",
        "title": "Keeper of the Hammer"
    },
    %{
        "id": 163,
        "key": "Taliyah",
        "name": "Taliyah",
        "title": "the Stoneweaver"
    },
    %{
        "id": 420,
        "key": "Illaoi",
        "name": "Illaoi",
        "title": "the Kraken Priestess"
    },
    %{
        "id": 74,
        "key": "Heimerdinger",
        "name": "Heimerdinger",
        "title": "the Revered Inventor"
    },
    %{
        "id": 12,
        "key": "Alistar",
        "name": "Alistar",
        "title": "the Minotaur"
    },
    %{
        "id": 5,
        "key": "XinZhao",
        "name": "Xin Zhao",
        "title": "the Seneschal of Demacia"
    },
    %{
        "id": 236,
        "key": "Lucian",
        "name": "Lucian",
        "title": "the Purifier"
    },
    %{
        "id": 106,
        "key": "Volibear",
        "name": "Volibear",
        "title": "the Thunder's Roar"
    },
    %{
        "id": 113,
        "key": "Sejuani",
        "name": "Sejuani",
        "title": "Fury of the North"
    },
    %{
        "id": 76,
        "key": "Nidalee",
        "name": "Nidalee",
        "title": "the Bestial Huntress"
    },
    %{
        "id": 86,
        "key": "Garen",
        "name": "Garen",
        "title": "The Might of Demacia"
    },
    %{
        "id": 89,
        "key": "Leona",
        "name": "Leona",
        "title": "the Radiant Dawn"
    },
    %{
        "id": 238,
        "key": "Zed",
        "name": "Zed",
        "title": "the Master of Shadows"
    },
    %{
        "id": 53,
        "key": "Blitzcrank",
        "name": "Blitzcrank",
        "title": "the Great Steam Golem"
    },
    %{
        "id": 33,
        "key": "Rammus",
        "name": "Rammus",
        "title": "the Armordillo"
    },
    %{
        "id": 161,
        "key": "Velkoz",
        "name": "Vel'Koz",
        "title": "the Eye of the Void"
    },
    %{
        "id": 51,
        "key": "Caitlyn",
        "name": "Caitlyn",
        "title": "the Sheriff of Piltover"
    },
    %{
        "id": 48,
        "key": "Trundle",
        "name": "Trundle",
        "title": "the Troll King"
    },
    %{
        "id": 203,
        "key": "Kindred",
        "name": "Kindred",
        "title": "The Eternal Hunters"
    },
    %{
        "id": 133,
        "key": "Quinn",
        "name": "Quinn",
        "title": "Demacia's Wings"
    },
    %{
        "id": 245,
        "key": "Ekko",
        "name": "Ekko",
        "title": "the Boy Who Shattered Time"
    },
    %{
        "id": 267,
        "key": "Nami",
        "name": "Nami",
        "title": "the Tidecaller"
    },
    %{
        "id": 50,
        "key": "Swain",
        "name": "Swain",
        "title": "the Master Tactician"
    },
    %{
        "id": 44,
        "key": "Taric",
        "name": "Taric",
        "title": "the Shield of Valoran"
    },
    %{
        "id": 134,
        "key": "Syndra",
        "name": "Syndra",
        "title": "the Dark Sovereign"
    },
    %{
        "id": 497,
        "key": "Rakan",
        "name": "Rakan",
        "title": "The Charmer"
    },
    %{
        "id": 72,
        "key": "Skarner",
        "name": "Skarner",
        "title": "the Crystal Vanguard"
    },
    %{
        "id": 201,
        "key": "Braum",
        "name": "Braum",
        "title": "the Heart of the Freljord"
    },
    %{
        "id": 45,
        "key": "Veigar",
        "name": "Veigar",
        "title": "the Tiny Master of Evil"
    },
    %{
        "id": 101,
        "key": "Xerath",
        "name": "Xerath",
        "title": "the Magus Ascendant"
    },
    %{
        "id": 42,
        "key": "Corki",
        "name": "Corki",
        "title": "the Daring Bombardier"
    },
    %{
        "id": 111,
        "key": "Nautilus",
        "name": "Nautilus",
        "title": "the Titan of the Depths"
    },
    %{
        "id": 103,
        "key": "Ahri",
        "name": "Ahri",
        "title": "the Nine-Tailed Fox"
    },
    %{
        "id": 126,
        "key": "Jayce",
        "name": "Jayce",
        "title": "the Defender of Tomorrow"
    },
    %{
        "id": 122,
        "key": "Darius",
        "name": "Darius",
        "title": "the Hand of Noxus"
    },
    %{
        "id": 23,
        "key": "Tryndamere",
        "name": "Tryndamere",
        "title": "the Barbarian King"
    },
    %{
        "id": 40,
        "key": "Janna",
        "name": "Janna",
        "title": "the Storm's Fury"
    },
    %{
        "id": 60,
        "key": "Elise",
        "name": "Elise",
        "title": "the Spider Queen"
    },
    %{
        "id": 67,
        "key": "Vayne",
        "name": "Vayne",
        "title": "the Night Hunter"
    },
    %{
        "id": 63,
        "key": "Brand",
        "name": "Brand",
        "title": "the Burning Vengeance"
    },
    %{
        "id": 104,
        "key": "Graves",
        "name": "Graves",
        "title": "the Outlaw"
    },
    %{
        "id": 16,
        "key": "Soraka",
        "name": "Soraka",
        "title": "the Starchild"
    },
    %{
        "id": 498,
        "key": "Xayah",
        "name": "Xayah",
        "title": "the Rebel"
    },
    %{
        "id": 30,
        "key": "Karthus",
        "name": "Karthus",
        "title": "the Deathsinger"
    },
    %{
        "id": 8,
        "key": "Vladimir",
        "name": "Vladimir",
        "title": "the Crimson Reaper"
    },
    %{
        "id": 26,
        "key": "Zilean",
        "name": "Zilean",
        "title": "the Chronokeeper"
    },
    %{
        "id": 55,
        "key": "Katarina",
        "name": "Katarina",
        "title": "the Sinister Blade"
    },
    %{
        "id": 102,
        "key": "Shyvana",
        "name": "Shyvana",
        "title": "the Half-Dragon"
    },
    %{
        "id": 19,
        "key": "Warwick",
        "name": "Warwick",
        "title": "the Uncaged Wrath of Zaun"
    },
    %{
        "id": 115,
        "key": "Ziggs",
        "name": "Ziggs",
        "title": "the Hexplosives Expert"
    },
    %{
        "id": 240,
        "key": "Kled",
        "name": "Kled",
        "title": "the Cantankerous Cavalier"
    },
    %{
        "id": 121,
        "key": "Khazix",
        "name": "Kha'Zix",
        "title": "the Voidreaver"
    },
    %{
        "id": 2,
        "key": "Olaf",
        "name": "Olaf",
        "title": "the Berserker"
    },
    %{
        "id": 4,
        "key": "TwistedFate",
        "name": "Twisted Fate",
        "title": "the Card Master"
    },
    %{
        "id": 20,
        "key": "Nunu",
        "name": "Nunu",
        "title": "the Yeti Rider"
    },
    %{
        "id": 107,
        "key": "Rengar",
        "name": "Rengar",
        "title": "the Pridestalker"
    },
    %{
        "id": 432,
        "key": "Bard",
        "name": "Bard",
        "title": "the Wandering Caretaker"
    },
    %{
        "id": 39,
        "key": "Irelia",
        "name": "Irelia",
        "title": "the Will of the Blades"
    },
    %{
        "id": 427,
        "key": "Ivern",
        "name": "Ivern",
        "title": "the Green Father"
    },
    %{
        "id": 62,
        "key": "MonkeyKing",
        "name": "Wukong",
        "title": "the Monkey King"
    },
    %{
        "id": 22,
        "key": "Ashe",
        "name": "Ashe",
        "title": "the Frost Archer"
    },
    %{
        "id": 429,
        "key": "Kalista",
        "name": "Kalista",
        "title": "the Spear of Vengeance"
    },
    %{
        "id": 84,
        "key": "Akali",
        "name": "Akali",
        "title": "the Fist of Shadow"
    },
    %{
        "id": 254,
        "key": "Vi",
        "name": "Vi",
        "title": "the Piltover Enforcer"
    },
    %{
        "id": 32,
        "key": "Amumu",
        "name": "Amumu",
        "title": "the Sad Mummy"
    },
    %{
        "id": 117,
        "key": "Lulu",
        "name": "Lulu",
        "title": "the Fae Sorceress"
    },
    %{
        "id": 25,
        "key": "Morgana",
        "name": "Morgana",
        "title": "Fallen Angel"
    },
    %{
        "id": 56,
        "key": "Nocturne",
        "name": "Nocturne",
        "title": "the Eternal Nightmare"
    },
    %{
        "id": 131,
        "key": "Diana",
        "name": "Diana",
        "title": "Scorn of the Moon"
    },
    %{
        "id": 136,
        "key": "AurelionSol",
        "name": "Aurelion Sol",
        "title": "The Star Forger"
    },
    %{
        "id": 143,
        "key": "Zyra",
        "name": "Zyra",
        "title": "Rise of the Thorns"
    },
    %{
        "id": 112,
        "key": "Viktor",
        "name": "Viktor",
        "title": "the Machine Herald"
    },
    %{
        "id": 69,
        "key": "Cassiopeia",
        "name": "Cassiopeia",
        "title": "the Serpent's Embrace"
    },
    %{
        "id": 75,
        "key": "Nasus",
        "name": "Nasus",
        "title": "the Curator of the Sands"
    },
    %{
        "id": 29,
        "key": "Twitch",
        "name": "Twitch",
        "title": "the Plague Rat"
    },
    %{
        "id": 36,
        "key": "DrMundo",
        "name": "Dr. Mundo",
        "title": "the Madman of Zaun"
    },
    %{
        "id": 61,
        "key": "Orianna",
        "name": "Orianna",
        "title": "the Lady of Clockwork"
    },
    %{
        "id": 28,
        "key": "Evelynn",
        "name": "Evelynn",
        "title": "the Widowmaker"
    },
    %{
        "id": 421,
        "key": "RekSai",
        "name": "Rek'Sai",
        "title": "the Void Burrower"
    },
    %{
        "id": 99,
        "key": "Lux",
        "name": "Lux",
        "title": "the Lady of Luminosity"
    },
    %{
        "id": 14,
        "key": "Sion",
        "name": "Sion",
        "title": "The Undead Juggernaut"
    },
    %{
        "id": 164,
        "key": "Camille",
        "name": "Camille",
        "title": "the Steel Shadow"
    },
    %{
        "id": 11,
        "key": "MasterYi",
        "name": "Master Yi",
        "title": "the Wuju Bladesman"
    },
    %{
        "id": 13,
        "key": "Ryze",
        "name": "Ryze",
        "title": "the Rune Mage"
    },
    %{
        "id": 54,
        "key": "Malphite",
        "name": "Malphite",
        "title": "Shard of the Monolith"
    },
    %{
        "id": 34,
        "key": "Anivia",
        "name": "Anivia",
        "title": "the Cryophoenix"
    },
    %{
        "id": 98,
        "key": "Shen",
        "name": "Shen",
        "title": "the Eye of Twilight"
    },
    %{
        "id": 59,
        "key": "JarvanIV",
        "name": "Jarvan IV",
        "title": "the Exemplar of Demacia"
    },
    %{
        "id": 90,
        "key": "Malzahar",
        "name": "Malzahar",
        "title": "the Prophet of the Void"
    },
    %{
        "id": 154,
        "key": "Zac",
        "name": "Zac",
        "title": "the Secret Weapon"
    },
    %{
        "id": 79,
        "key": "Gragas",
        "name": "Gragas",
        "title": "the Rabble Rouser"
    }]


    def find_by_id(id) do
        Enum.find(@champions, fn champion -> champion[:id] == id end)
    end
end