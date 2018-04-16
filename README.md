# Backend service for buddy.gg
[![Build Status](https://travis-ci.org/BuddyGG/buddy_matching.png)](https://travis-ci.org/BuddyGG/buddy_matching)
[![Coverage Status](https://coveralls.io/repos/github/BuddyGG/buddy_matching/badge.svg?branch=master)](https://coveralls.io/github/BuddyGG/buddy_matching?branch=master)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

Somewhat Generic player matching service built with Phoenix, utilizing GenServers and sockets to avoid having an underlying database. 

The application is structered as an umbrella consisting of 3 apps.
- [riot_api](/apps/riot_api) for integration with Riot's API
- [fortnite_api](/apps/fortnite_api) for integration with Fortnite's unofficial API
- [buddy_matching](apps/buddy_matching) for in-memory storage of connected players and matching logic
- [buddy_matching_web](apps/buddy_matching_web) main phoenix app from which the matching and API is exposed

Currently built only to support matching players from League of Legends, but can ideally be easily extended to support multiple games.

## Run local
To start the server:
- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`
Now you can visit localhost:4000 from your browser.

To test interactively in IEx:
- Install depedencies with `mix.deps.get`
- Star IEx with `iex -S mix phx.server`

To test interactively with Riot's API in IEx, create a local dev.secret.exs from the [template](config/dev.secret.example.exs), and fill in your 24h API key generated at https://developer.riotgames.com/.
## Run tests
`mix test`

## Development
*Features* should be implemented on feature branches based on [development] and rebased thereinto with Pull Requests.
New features should not add any issues to `mix credo`.

*Releases* should be merged from [development] into [master], whereafter [master] is rebased into [development].

## Deployment
**Development**:  
Branch 'development' is automatically deployed to Heroku at: https://lolbuddy.herokuapp.com/api/  

Test: https://lolbuddy.herokuapp.com/api/summoner/euw/Lethly

**Master**:  
Branch Master is manually deployed to DO at https://api.buddy.gg/api/  

Test: https://api.buddy.gg/api/summoner/euw/Lethly 

Deployment is handled with [edeliver](https://github.com/edeliver/edeliver) and [conform](https://github.com/bitwalker/conform). See the respected repos for more information. 
