defmodule AirTrafficControl do
  use Application

  def start(:normal, args) do
    start_node(args)
  end
  def start({:takeover, other_node}, args) do
    IO.puts("[Takeover] #{inspect other_node}")
    start_node(args)
  end

  def start_node(args) do
    supervisor = AirTrafficControl.ControlTowerSupervisor.start_link(args)
    airports = Application.get_env(:air_traffic_control, :airports)

    airports
      |> List.foldl([], fn {name, count}, acc -> acc ++ open_landing_strips(name, count) end)

    supervisor
  end

  def stop(_) do
    :ok
  end

  defp open_landing_strips(name, count) do
    AirTrafficControl.ControlTowerSupervisor.start_control_tower(name)
    open_landing_strips(name, count, [])
  end

  defp open_landing_strips(_name, 0, acc), do: acc
  defp open_landing_strips(name, count, acc) do
    open_landing_strips(name, count - 1, acc ++ [AirTrafficControl.ControlTower.open_landing_strip(name)])
  end
end
