defmodule LolBuddy.Application do
  @moduledoc """
  Application configuration. The PlayerServer.Supervisor is started from here.
  """

  use Application
  alias LolBuddyWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    api_key = System.get_env("RIOT_API_KEY")

    if api_key do
      Application.put_env(:lol_buddy, :riot_api_key, api_key)
    end

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Endpoint, []),
      supervisor(LolBuddy.PlayerServer.Supervisor, []),
      supervisor(LolBuddyWeb.Presence, [])
      # Start your own worker by calling:
      #   LolBuddy.Worker.start_link(arg1, arg2, arg3)
      #   worker(LolBuddy.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LolBuddy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
