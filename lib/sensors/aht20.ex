defmodule HelloScenic.Sensors.Aht20 do
  @moduledoc """
  https://wiki.seeedstudio.com/Grove-AHT20-I2C-Industrial-Grade-Temperature&Humidity-Sensor/
  """
  @behaviour HelloScenic.Sensors.Aht20Behaviour

  require Logger

  alias Circuits.I2C

  @address 0x38

  @spec read(bus_name :: String.t()) ::
          {:ok, {temperature :: float(), humidity :: float()}} | {:error, term()}
  def read(bus_name) when bus_name in ["i2c-1"] do
    {:ok, bus_ref} = I2C.open(bus_name)

    try do
      if calibrated?(bus_ref) do
        initialize(bus_ref)
      end

      read_impl(bus_ref)
    after
      I2C.close(bus_ref)
    end
  end

  def calibrated?(bus_ref) when is_reference(bus_ref) do
    case I2C.write_read(bus_ref, @address, <<0x71>>, 1) do
      {:ok, <<busy::1, _::3, cal::1, _::3>> = _state} ->
        if busy == 0 do
          if cal == 1, do: true, else: false
        else
          Logger.error("busy: #{inspect(busy)}")
          false
        end

      {:error, term} ->
        Logger.error("#{inspect(term)}")
        false
    end
  end

  defp initialize(bus_ref) when is_reference(bus_ref) do
    case I2C.write(bus_ref, @address, <<0xBE, 0x08, 0x00>>) do
      :ok ->
        Process.sleep(10)
        :ok

      error ->
        error
    end
  end

  defp read_impl(bus_ref) when is_reference(bus_ref) do
    case I2C.write(bus_ref, @address, <<0xAC, 0x33, 0x00>>) do
      :ok ->
        Process.sleep(80)

        case I2C.read(bus_ref, @address, 7) do
          {:ok, binary} -> {:ok, convert(binary)}
          error -> error
        end

      error ->
        error
    end
  end

  defp convert(binary) when is_binary(binary) do
    <<_state::8, h::20, t::20, _crc::8>> = binary

    humidity = h / :math.pow(2, 20) * 100
    temperature = t / :math.pow(2, 20) * 200 - 50

    {temperature, humidity}
  end
end
