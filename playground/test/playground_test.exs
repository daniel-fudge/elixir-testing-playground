defmodule PlaygroundTest do
  @moduledoc "This module tests the processor function.

  ASSUMPTIONS:
  ----------------------------------------------------
    - Window size to sample full signal is 5
    - Signal frequerncy is 1 Hz
    - The 'pre' window ends at the first 'True' instance of 'light_on'
    - The 'test' window ends at the first 'False' instance of 'light_on' after the 'pre' window
    - The 'post' starts after the test 'window' with a cycle buffer
    - The 'light_on' column is #2
    - The sensor data to us is in the 4th column
    - The processor accepts integers
  "
  use ExUnit.Case
  doctest Playground

  @data_path Path.expand("../deps/flanders-data-normally-off-algorithm", __DIR__)
  @window 5

  test "normally off algorithm regression test" do

    @data_path
    |> Path.join("test_labels.csv")
    |> read_csv
    |> Enum.map(fn [name, expected] -> check_processor(name, expected) end)

    assert true
  end


  defp check_processor(name, _expected) do
      #TODO - Read signal, extract 5 second window, pass to processor
      @data_path
      |> Path.join("processed-data")
      |> Path.join(name <> ".csv")
      |> read_csv
      |> split_signal
      |> check_signal

  end

  defp check_signal do

  end

  defp read_file(source) do
    # Generic file reading function
    case File.read(source) do
      {:ok, contents} ->
        contents
      {:error, reason} ->
        IO.inspect "Error reading #{source}: #{reason}"
        ""
    end
  end

  defp read_csv(csv_path) do
    # Removes header and blank lines and return 2D list of CSV data
    [ _ | data_lines] = csv_path
      |> read_file
      |> String.replace("\r\n", "\n")
      |> String.split("\n")
      |> Enum.map(fn x -> String.split(x, ",") end)
      |> Enum.filter(fn x -> length(x) > 1 end)
    data_lines
  end

  defp split_signal(full_signal) do
    # Extract the relay "light_on" flag
    light_on = full_signal
      |> Enum.map(fn x -> Enum.at(x, 1) end)
      |> Enum.map(fn x -> x == "True" end)

    # Extract the light signal
    signal = full_signal
      |> Enum.map(fn x -> Enum.at(x, 3) end)
      |> Enum.map(fn x -> String.to_float(x) end)
      |> Enum.map(fn x -> round(x) end)


    # Extract the pre signal
    pre_end_index = Enum.find_index(light_on, fn x -> x end)
    pre = Enum.slice(signal, pre_end_index - @window + 1, @window)

    # Remove the data upto and including the pre signal plus 1 cycle
    {_, light_on} = Enum.split(light_on, pre_end_index + 2)
    {_, signal} = Enum.split(signal, pre_end_index + 2)

    # Extract the test and post signals
    test_end_index = Enum.find_index(light_on, fn x -> !x end) - 1
    test = Enum.slice(signal, test_end_index - @window + 1, @window)
    post = Enum.slice(signal, test_end_index + 2, @window)

    # Return the pre, test and post signals
    [pre, test, post]
  end

end
