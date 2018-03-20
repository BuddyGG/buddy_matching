defmodule BuddyMatching.Application do
  @moduledoc """
  Application configuration. The PlayerServer.Supervisor is started from here.
  """

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BuddyMatching.PlayerServer.Supervisor, [])
      # Start your own worker by calling:
      #   BuddyMatching.Worker.start_link(arg1, arg2, arg3)
      #   worker(BuddyMatching.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BuddyMatching.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
