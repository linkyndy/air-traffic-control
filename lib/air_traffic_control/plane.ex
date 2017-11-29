defmodule AirTrafficControl.Plane do
  use GenStateMachine, callback_mode: :state_functions

  alias AirTrafficControl.ControlTower

  def start_link(control_tower) do
    plane = create_plane(control_tower)
    GenStateMachine.start(__MODULE__, {:in_air, plane})
  end

  # API

  def permission_to_land(plane) do
    GenStateMachine.call(plane, :permission_to_land)
  end

  def land(plane) do
    GenStateMachine.cast(plane, :land)
  end

  def rest(plane) do
    GenStateMachine.cast(plane, :rest)
  end

  # Callbacks

  def in_air({:call, from}, :permission_to_land, plane) do
    %{control_tower: control_tower, flight_number: flight_number} = plane
    result = ControlTower.permission_to_land(control_tower, plane)
    IO.puts("#{flight_number} asked #{inspect control_tower} for permission to land, got #{inspect result}")

    case result do
      :cannot_land ->
        IO.puts("#{flight_number} cannot land")
        {:next_state, :in_air, plane, {:reply, from, :cannot_land}}
      landing_strip ->
        plane = %{plane | landing_strip: landing_strip}
        {:next_state, :prepare_for_landing, plane, {:reply, from, :got_permission}}
    end
  end
  def in_air(event_type, event, data) do
    handle_event(event_type, event, :in_air, data)
  end

  def prepare_for_landing(:cast, :land, %{control_tower: control_tower, landing_strip: landing_strip} = plane) do
    ControlTower.land(control_tower, plane, landing_strip)
    {:next_state, :landed, plane}
  end

  def landed(event_type, event, data) do
    handle_event(event_type, event, :landed, data)
  end

  def handle_event({:call, from}, event, _state, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end
  def handle_event(:cast, :rest, _, data) do
    {:stop, :normal, data}
  end

  def terminate(:normal, _, %{flight_number: flight_number} = data) do
    IO.puts("#{flight_number} finished")
  end

  defp create_plane(control_tower) do
    flight_number = generate_flight_number()
    %{flight_number: flight_number, control_tower: control_tower, landing_strip: nil}
  end

  defp generate_flight_number() do
    code = ["AB", "BL", "CG"] |> Enum.random
    number = Integer.to_string(:rand.uniform(1_000))
    code <> number
  end
end
