defmodule LolBuddy.PlayerServer.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(LolBuddy.PlayerServer, [], restart: :transient)
    ]

    # only restart the the single broken processor
    supervise(children, strategy: :simple_one_for_one)
  end
end
