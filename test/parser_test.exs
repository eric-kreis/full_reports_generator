defmodule ReportsGeneratorParallel.ParserTest do
  use ExUnit.Case

  alias ReportsGeneratorParallel.Parser

  describe "parse_file/1" do
    test "parses the file" do
      filename = "report_1.csv"

      response =
        filename
        |> Parser.parse_file()
        |> Enum.member?(["daniele", 7, 29, "abril", 2018])

      assert response == true
    end
  end
end
