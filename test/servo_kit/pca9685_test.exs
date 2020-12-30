defmodule ServoKit.PCA9685Test do
  use ExUnit.Case
  # doctest ServoKit.PCA9685

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias ServoKit.PCA9685

  setup do
    setup_i2c_mock()
    :ok
  end

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "start" do
    test "no config" do
      assert {:ok, state} = PCA9685.start()
      assert %PCA9685.State{i2c_ref: _ref, mode1: 0xA1, mode2: 0x04, pca9685_address: 0x40, prescale: 121} = state
    end

    test "blank config" do
      assert {:ok, _} = PCA9685.start(%{})
    end

    test "some config" do
      assert {:ok, _} = PCA9685.start(%{i2c_bus_name: "i2c-1"})
    end
  end

  test "reset" do
    {:ok, state} = PCA9685.start(%{})
    assert %PCA9685.State{} = PCA9685.reset(state)
  end

  test "sleep" do
    {:ok, state} = PCA9685.start(%{})
    assert %PCA9685.State{mode1: 0xB1} = PCA9685.sleep(state)
  end

  test "wake_up" do
    {:ok, state} = PCA9685.start(%{})
    assert %PCA9685.State{mode1: 0xA1} = PCA9685.wake_up(state)
  end

  describe "set_pwm_frequency" do
    test "calculate prescale" do
      {:ok, state} = PCA9685.start(%{})
      assert %PCA9685.State{prescale: 101} = PCA9685.set_pwm_frequency(state, 60)
      assert %PCA9685.State{prescale: 86} = PCA9685.set_pwm_frequency(state, 70)
    end
  end

  describe "set_pwm_duty_cycle" do
    test "one channel" do
      {:ok, state} = PCA9685.start(%{})
      state = PCA9685.set_pwm_duty_cycle(state, 1, 60.0)

      assert [
               nil,
               60.0,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil,
               nil
             ] == state.duty_cycles
    end

    test "all channels" do
      {:ok, state} = PCA9685.start(%{})
      state = PCA9685.set_pwm_duty_cycle(state, :all, 60.0)

      assert [
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0,
               60.0
             ] == state.duty_cycles
    end
  end

  defp setup_i2c_mock() do
    # https://hexdocs.pm/mox/Mox.html#stub/3
    ServoKit.MockI2C
    |> stub(:open, fn _i2c_bus -> {:ok, Kernel.make_ref()} end)
    |> stub(:write, fn _ref, _address, _data -> :ok end)
  end
end
