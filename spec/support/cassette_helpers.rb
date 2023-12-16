module CassetteHelpers
  def use_stats_cassette(year:, tag: nil, &)
    use_cassette(:stats, year:, tag:, &)
  end

  def use_puzzle_cassette(year:, day:, tag: nil, &)
    use_cassette(:puzzle, year:, day:, tag:, &)
  end

  def use_input_cassette(year:, day:, tag: nil, &)
    use_cassette(:input, year:, day:, tag:, &)
  end

  def use_solution_cassette(year:, day:, level:, tag: nil, &)
    use_cassette(:solution, year:, day:, level:, tag:, &)
  end

  private

  def use_cassette(type, year:, day: nil, level: nil, tag: nil, &)
    VCR.use_cassette(cassette_name(type, year, day, level, tag), &)
  end

  def cassette_name(type, year, day, level, tag)
    [type, year, formatted_day(day), level, tag]
      .compact
      .map { |part| part.to_s.gsub("_", "-") }
      .join("-")
  end

  def formatted_day(day)
    day&.to_s&.rjust(2, "0")
  end
end
