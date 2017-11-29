defmodule AirTrafficControl.Mixfile do
  use Mix.Project

  def project do
    [
      app: :air_traffic_control,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AirTrafficControl, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_state_machine, "~> 2.0.1"},
      {:distillery, "~> 1.5"}
    ]
  end
end
