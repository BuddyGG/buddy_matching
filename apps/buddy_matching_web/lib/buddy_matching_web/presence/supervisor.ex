defmodule BuddyMatchingWeb.Presence.Supervisor do
  @moduledoc """
  The Supervisor responsible for the PlayerServers spawned for each region.
  Failures are handled individually on each PlayerServer and thereby only results
  in restarts of the single failing instance.
  """

  use Supervisor
  alias BuddyMatchingWeb.Presence.LeaveTracker

  @doc """
  Default constructor for PlayerServer, in which case
  we name the PlayerServer based on the module
  """

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Starts a PlayerServer with potential options.
  """

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Define all the child specs for the various regions
  and start them all with one_for_one strategy.
  """

  def init(:ok) do
    children = [worker(LeaveTracker, [])]

    # only restart the the single broken processor
    Supervisor.init(children, strategy: :one_for_one)
  end
end
