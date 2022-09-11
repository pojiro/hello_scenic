import Config

# Add configuration that is only needed when running on the host here.

config :hello_scenic, :viewport,
  size: {800, 600},
  theme: :dark,
  default_scene: HelloScenic.Scene.Sensor,
  drivers: [
    [
      module: Scenic.Driver.Local,
      window: [title: "hello_scenic"],
      on_close: :stop_system
    ]
  ]
