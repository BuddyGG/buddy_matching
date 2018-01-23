# Backend service for Buddy.gg
Somewhat generic player matching service built with phoenix, utilizing genservers and sockets to avoid having an underlying database.
Currently build only support matching players from League of Legends, but can quite easily be expanded to other games

## Run local
To start the server:
  - Install dependencies with mix deps.get
  - Start Phoenix endpoint with mix phx.server
Now you can visit localhost:4000 from your browser.

## Deploy to production
Deployment is handled with [edeliver](https://github.com/edeliver/edeliver) and [conform](https://github.com/bitwalker/conform). See the respected repos for more information. 

