# source: https://github.com/eric-kreis/reports_generator
defmodule ReportsGeneratorParallel do
  alias ReportsGeneratorParallel.Parser

  @moduledoc """
  Documentation for `ReportsGeneratorParallel`.
  """

  @doc """
  Build report from one or many CSV files.

  ## Examples

      iex> ReportsGeneratorParallel.build()
      {:error, "Please, provide a string or a list of strings"}

      iex> ReportsGeneratorParallel.build(1)
      {:error, "Please, provide a string or a list of strings"}

      iex> ReportsGeneratorParallel.build("report_complete.csv")
      %{
        "all_hours" => %{
          "cleiton" => 13797,
          "daniele" => 13264,
          ...
        },
        "hours_per_month" => %{
          "cleiton" => %{
            "abril" => 1161,
            "agosto" => 1149,
            "dezembro" => 1100,
            ...
          },
          "daniele" => %{
            "abril" => 1138,
            ...
          }
        },
        "hours_per_year" => %{
          "cleiton" => %{
            2016 => 2699,
            2017 => 2684,
            ...
          },
          "daniele" => %{
            2016 => 2573,
            ...
          }
        }
      }

      iex> ReportsGeneratorParallel.build(["report_1.csv", "report_2.csv", "report_3.csv"])
      %{
        "all_hours" => %{
          "cleiton" => 13797,
          "daniele" => 13264,
          ...
        },
        "hours_per_month" => %{
          "cleiton" => %{
            "abril" => 1161,
            "agosto" => 1149,
            "dezembro" => 1100,
            ...
          },
          "daniele" => %{
            "abril" => 1138,
            ...
          }
        },
        "hours_per_year" => %{
          "cleiton" => %{
            2016 => 2699,
            2017 => 2684,
            ...
          },
          "daniele" => %{
            2016 => 2573,
            ...
          }
        }
      }

  """
  def build, do: {:error, "Please, provide a string or a list of strings"}

  def build(filename) when is_binary(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(build_report(), &gen_report(&1, &2))
  end

  def build(filenames) when not is_list(filenames) do
    {:error, "Please, provide a string or a list of strings"}
  end

  def build(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(build_report(), fn {:ok, acc_report}, curr_report ->
      merge_reports(acc_report, curr_report)
    end)
  end

  defp build_report(all_hours \\ %{}, hours_per_month \\ %{}, hours_per_year \\ %{}) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp gen_report(line, acc) do
    build_report(
      gen_all_hours_report(line, acc),
      gen_month_hours_report(line, acc),
      gen_year_hours_report(line, acc)
    )
  end

  defp merge_reports(acc_report, curr_report) do
    %{
      "all_hours" => acc_all_hours,
      "hours_per_month" => acc_hours_per_month,
      "hours_per_year" => acc_hours_per_year
    } = acc_report

    %{
      "all_hours" => curr_all_hours,
      "hours_per_month" => curr_hours_per_month,
      "hours_per_year" => curr_hours_per_year
    } = curr_report

    build_report(
      sum_report_values(acc_all_hours, curr_all_hours),
      sum_report_values(acc_hours_per_month, curr_hours_per_month),
      sum_report_values(acc_hours_per_year, curr_hours_per_year)
    )
  end

  defp sum_report_values(map1, map2) when is_map(map1) and is_map(map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> sum_report_values(value1, value2) end)
  end

  defp sum_report_values(value1, value2) do
    value1 + value2
  end

  defp gen_all_hours_report([name, hours, _, _, _], %{"all_hours" => all_hours}) do
    sum_hours(all_hours, name, hours)
  end

  defp gen_month_hours_report([name, hours, _, month, _], %{"hours_per_month" => hours_per_month}) do
    gen_nested_hours_report(hours_per_month, name, month, hours)
  end

  defp gen_year_hours_report([name, hours, _, _, year], %{"hours_per_year" => hours_per_year}) do
    gen_nested_hours_report(hours_per_year, name, year, hours)
  end

  defp gen_nested_hours_report(acc_hours, dev_name, hours_key, hours)
       when is_map_key(acc_hours, dev_name) do
    dev_nested_hours = acc_hours[dev_name]

    update_nested_hours(
      acc_hours,
      dev_name,
      sum_hours(dev_nested_hours, hours_key, hours)
    )
  end

  defp gen_nested_hours_report(acc_hours, dev_name, hours_key, hours) do
    update_nested_hours(acc_hours, dev_name, %{hours_key => hours})
  end

  defp sum_hours(acc_hours, hours_key, hours) when is_map_key(acc_hours, hours_key) do
    %{acc_hours | hours_key => acc_hours[hours_key] + hours}
  end

  defp sum_hours(acc_hours, hours_key, hours) do
    Map.merge(acc_hours, %{hours_key => hours})
  end

  defp update_nested_hours(acc_hours, dev_name, dev_map) do
    Map.merge(acc_hours, %{dev_name => dev_map})
  end
end
