use Mix.Config

config :kernel,
  distributed: [
    {:air_traffic_control, 10_000, [:"air1@127.0.0.1", {:"air2@127.0.0.1", :"air3@127.0.0.1"}]}
  ],
  sync_nodes_timeout: 10_000,
  sync_nodes_mandatory: [:"air1@127.0.0.1", :"air2@127.0.0.1"]
