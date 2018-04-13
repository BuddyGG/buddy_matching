defmodule BuddyMatchingWeb.Router do
  use BuddyMatchingWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", BuddyMatchingWeb do
    pipe_through(:api)

    get("/summoner/:region/:name", SummonerController, :show)
    get("/fortnite/:platform/:name", FortniteController, :show)
    get("/auth/request", AuthController, :show)
    get("/stats", StatsController, :show)
  end
end
