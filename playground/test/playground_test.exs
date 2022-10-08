defmodule PlaygroundTest do
  use ExUnit.Case
  doctest Playground

  @data_path Path.expand("../deps/flanders-data-normally-off-algorithm", __DIR__)

  test "normally off algorithm regression test" do

    @data_path
    |> Path.join("test_labels.csv")
    |> read_csv
    |> Enum.map(fn [name, expected] -> check_processor(name, expected) end)

    assert true
  end


  defp check_processor(name, expected) do
      #TODO - Read signal, extract 5 second window, pass to processor
  end

  defp read_file(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents
      {:error, reason} ->
        IO.inspect "Error reading #{source}: #{reason}"
        ""
    end
  end

  defp read_csv(csv_path) do
    # Replace any crazy line endings and split lines
    [ _ | data_lines] = csv_path
      |> read_file
      |> String.replace("\r\n", "\n")
      |> String.split("\n")
      |> List.delete_at(0)
      |> Enum.map(fn x -> String.split(x, ",") end)
    data_lines
  end


end
