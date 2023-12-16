module PathHelpers
  def puzzle_content_path(dir:, day:)
    file = "day_#{formatted_day(day)}.md"

    Pathname(dir).join(file)
  end

  def puzzle_input_path(dir:)
    Pathname(dir).join("input")
  end

  private

  def formatted_day(day)
    day&.to_s&.rjust(2, "0")
  end
end
