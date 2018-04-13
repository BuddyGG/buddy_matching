# Fortnite Api
This app contains an integration with the Fortnite's unofficial API.

It uses a [GenServer](lib/fortnite_api/access_server.ex) for maintaining a shared
valid access token to be used for requests to the actual Fortnite API.

The app currently only supports duo queue as well as platforms `pc/ps4/xb1`. 
The stats of a given player are accessed through [`FortniteApi.fetch_stats/2`](lib/fortnite_api.ex#L88-L102).

## Test
To test locally, see [this](https://github.com/qlaffont/fortnite-api/blob/master/README.md#init) for guidance on how to retrieve necessary values. Once you have these, create a local `config/dev.secret.exs` file from the given [example](config/dev.secret.example.exs) with the retrieved values.
