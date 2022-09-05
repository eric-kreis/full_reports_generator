defmodule ReportsGeneratorParallel.Parser do
  @months %{
    "1": "Janeiro",
    "2": "Fevereiro",
    "3": "Março",
    "4": "Abril",
    "5": "Maio",
    "6": "Junho",
    "7": "Julho",
    "8": "Agosto",
    "9": "Setembro",
    "10": "Outubro",
    "11": "Novembro",
    "12": "Dezembro"
  }

  def parse_file(file_name) do
    "reports/#{file_name}"
    |> File.stream!()
    |> Stream.map(&parse_line(&1))
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(3, &get_month_name(String.to_atom(&1)))
    |> Enum.map(&parse_string_to_num/1)
  end

  defp parse_string_to_num(payload) do
    case Integer.parse(payload) do
      :error -> String.downcase(payload)
      {value, ""} -> value
    end
  end

  defp get_month_name(month_number), do: @months[month_number]
end
