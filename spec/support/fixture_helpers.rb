module FixtureHelpers
  def fixture(file)
    spec_dir.join("fixtures").join(file).read
  end

  def puzzle_fixture(year:, day:)
    fixture("puzzle-#{year}-#{formatted_day(day)}.md")
  end

  def input_fixture(year:, day:)
    fixture("input-#{year}-#{formatted_day(day)}")
  end

  private

  def formatted_day(day)
    day&.to_s&.rjust(2, "0")
  end
end
