defmodule LolBuddyWeb.Router do
  use LolBuddyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LolBuddyWeb do
    pipe_through :api
  end
end
