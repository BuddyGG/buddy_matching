defmodule FortniteApi.Application do
  @moduledoc """
  Application configuration. The AccessToken Supervisor is started from here.
  """

  use Application
  alias FortniteApi.AccessServer

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # We don't want to start the AccessServer during testing
    children = if Mix.env() != :test, do: [worker(AccessServer, [])], else: []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
