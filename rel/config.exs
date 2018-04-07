# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
["rel", "plugins", "*.exs"]
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :buddy,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"<dyw$,b6t]NxpB)lpJ4/)TQHQNSa?!t0^skw4HTqu[)A*>q)mM=V8vqfTQ(b0E7D"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"uh}JO_:x%IW@w4|u{eB&Z1dWHPEzD@g}5S_n?a*|xRN{L.cSq5Pu%DR|.yZ=3Q_i"
  set output_dir: "rel/buddy"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :buddy do
  set version: "1.2.0"
  plugin Conform.ReleasePlugin
  set applications: [
    :runtime_tools,
    buddy_matching: :permanent,
    buddy_matching_web: :permanent,
    riot_api: :permanent,
    fortnite_api: :permanent
  ]
end
