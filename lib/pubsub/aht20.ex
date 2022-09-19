defmodule HelloScenic.PubSub.Aht20 do
  use GenServer

  alias Scenic.PubSub

  @version "0.1.0"
  @description "aht20"

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(_) do
    PubSub.register(:aht20, version: @version, description: @description)

    Process.send_after(self(), :measure, 0)

    {:ok, %{}}
  end

  def handle_info(:measure, state) do
    {:ok, {_t, _h} = tuple} = HelloScenic.Sensors.Aht20Behaviour.module().read("i2c-1")

    PubSub.publish(:aht20, tuple)

    Process.send_after(self(), :measure, 200)

    {:noreply, state}
  end
end
