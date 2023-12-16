module PathHelpers
  def puzzle_content_path(dir:, day:)
    file = "day_#{formatted_day(day)}.md"

    Pathname(dir).join(file)
  end

  def puzzle_input_path(dir:)
    Pathname(dir).join("input")
  end
end
