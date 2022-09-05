defmodule ReportsGeneratorParallelTest do
  use ExUnit.Case

  alias ReportsGeneratorParallel.Support.ReportFixture

  describe "build/1" do
    test "When passing filename, returns a report" do
      response = ReportsGeneratorParallel.build("report_complete.csv")

      assert response == ReportFixture.build()
    end

    test "When passing list of filenames, returns a report" do
      response = ReportsGeneratorParallel.build(["report_1.csv", "report_2.csv", "report_3.csv"])

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = ReportsGeneratorParallel.build()

      assert response == {:error, "Please, provide a string or a list of strings"}
    end

    test "When filename is not a string or a list, returns an error" do
      response = ReportsGeneratorParallel.build(1)

      assert response == {:error, "Please, provide a string or a list of strings"}
    end
  end
end
