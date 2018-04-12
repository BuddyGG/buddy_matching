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

    # Define workers and child supervisors to be supervised
    children = [worker(AccessServer, [])]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
