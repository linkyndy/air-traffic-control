defmodule AirTrafficControl.ControlTower do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end
  def start_link(_, name), do: start_link(name)

  def status(pid), do: GenServer.call(pid, :status)

  def open_landing_strip(pid), do: GenServer.call(pid, :open_landing_strip)

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

  defp create_landing_strip() do
    id = :rand.uniform(1_000_000)
    {id, %{id: id, free: true}}
  end
end
