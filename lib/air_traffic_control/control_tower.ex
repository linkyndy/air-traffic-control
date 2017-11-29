defmodule AirTrafficControl.ControlTower do
  use GenServer

  alias AirTrafficControl.Plane

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: {:global, name})
  end
  def start_link(_, name), do: start_link(name)

  def status(pid), do: GenServer.call({:global, pid}, :status)

  def open_landing_strip(pid), do: GenServer.call({:global, pid}, :open_landing_strip)

  def permission_to_land(pid, plane), do: GenServer.call({:global, pid}, {:permission_to_land, plane})

  def land(pid, plane, landing_strip), do: GenServer.call({:global, pid}, {:land, plane, landing_strip})

  # Internal callbacks for GenServer

  def init(airport) do
    {:ok, %{airport: airport}}
  end

  # Handle synchronous calls (handle_info and handle_cast for asynchronous)
  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end
  def handle_call(:open_landing_strip, _from, %{airport: airport} = state) do
    {id, landing_strip} = create_landing_strip()
    IO.puts("#{airport} opens new landing strip (#{id})")
    {:reply, landing_strip, Map.put(state, id, landing_strip)}
  end
  def handle_call({:permission_to_land, plane}, _from, %{airport: airport} = state) do
    free_landing_strips = Map.values(state)
      |> Enum.filter(fn landing_strip -> is_map(landing_strip) end)
      |> Enum.filter(fn landing_strip -> landing_strip[:free] end)

    case free_landing_strips do
      [] ->
        IO.puts("#{airport} cannot find a free landing strip")
        {:reply, :cannot_land, state}
      # Only pick the first one available
      [landing_strip | _] ->
        landing_strip = %{landing_strip | free: false}
        state = %{state | landing_strip[:id] => landing_strip}
        {:reply, landing_strip, state}
    end
  end
  def handle_call({:land, plane, landing_strip}, from, state) do
    %{airport: airport} = state
    %{flight_number: flight_number} = plane
    IO.puts("#{airport} flight #{flight_number} is approaching the runway #{inspect landing_strip}")
    :timer.sleep(400)
    IO.puts("#{airport} is freeing up the runway #{inspect landing_strip}")
    landing_strip = %{landing_strip | free: true}
    # Plane.rest(plane)
    {:reply, :ok, Map.put(state, landing_strip[:id], landing_strip)}
  end

  defp create_landing_strip() do
    id = :rand.uniform(1_000_000)
    {id, %{id: id, free: true}}
  end
end
