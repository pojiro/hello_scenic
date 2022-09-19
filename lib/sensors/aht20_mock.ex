defmodule HelloScenic.Sensors.Aht20Mock do
  @behaviour HelloScenic.Sensors.Aht20Behaviour

  def read(_) do
    {:ok, {25.0, 50.0}}
  end
end
