defmodule BuddyMatching.PlayerServer.Supervisor do
  @moduledoc """
  The Supervisor responsible for the PlayerServers spawned for each region.
  Failures are handled individually on each PlayerServer and thereby only results
  in restarts of the single failing instance.
  """

  use Supervisor
  alias BuddyMatching.PlayerServer

  @doc """
  Default constructor for PlayerServer, in which case
  we name the PlayerServer based on the module
  """
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Define all the child specs for the various regions
  and start them all with one_for_one strategy.
  """
  def init(:ok) do
    lol_servers = [
      Supervisor.child_spec({PlayerServer, name: {:global, :br}}, id: :worker_br),
      Supervisor.child_spec({PlayerServer, name: {:global, :eune}}, id: :worker_eune),
      Supervisor.child_spec({PlayerServer, name: {:global, :euw}}, id: :worker_euw),
      Supervisor.child_spec({PlayerServer, name: {:global, :jp}}, id: :worker_jp),
      Supervisor.child_spec({PlayerServer, name: {:global, :kr}}, id: :worker_kr),
      Supervisor.child_spec({PlayerServer, name: {:global, :lan}}, id: :worker_lan),
      Supervisor.child_spec({PlayerServer, name: {:global, :las}}, id: :worker_las),
      Supervisor.child_spec({PlayerServer, name: {:global, :na}}, id: :worker_na),
      Supervisor.child_spec({PlayerServer, name: {:global, :oce}}, id: :worker_oce),
      Supervisor.child_spec({PlayerServer, name: {:global, :tr}}, id: :worker_tr),
      Supervisor.child_spec({PlayerServer, name: {:global, :ru}}, id: :worker_ru),
      Supervisor.child_spec({PlayerServer, name: {:global, :pbe}}, id: :worker_pbe)
    ]

    fortnite_servers = [
      Supervisor.child_spec({PlayerServer, name: {:global, :pc}}, id: :worker_pc),
      Supervisor.child_spec({PlayerServer, name: {:global, :ps4}}, id: :worker_ps4),
      Supervisor.child_spec({PlayerServer, name: {:global, :xb1}}, id: :worker_xb1)
    ]

    children = lol_servers ++ fortnite_servers

    # only restart the the single broken processor
    Supervisor.init(children, strategy: :one_for_one)
  end
end
