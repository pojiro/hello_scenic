defmodule HelloScenic.Sensors.Aht20Behaviour do
  @callback read(i2c_bus_name :: String.t()) ::
              {:ok, {temperature :: float(), humidity :: float()}} | {:error, term()}

  def module() do
    case Application.get_env(:hello_scenic, :target) do
      :host -> HelloScenic.Sensors.Aht20Mock
      _ -> HelloScenic.Sensors.Aht20
    end
  end
end
