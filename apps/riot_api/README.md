# Riot Api
This app contains the integration with the Riot API.
Currently we use a local mapping of Champion ID to Champion Name to avoid
otherwise redundant requests to Riot's API.

### Test 
To test locally, generate a temporary API key from [Riot's Developer Website](https://developer.riotgames.com/)
and create a local `config/dev.secret.exs` file from the given [example](config/dev.secret.example.exs) with 
generated API key.
