import Config

config :exla, :clients, default: [platform: :cuda],
  cuda: [platform: :cuda],
  rocm: [platform: :rocm],
  tpu: [platform: :tpu],
  host: [platform: :host]

config :nx, :default_backend, EXLA.Backend
