module RequestHelpers
  BASE = "https://adventofcode.com".freeze

  def stats_url(stats)
    "#{BASE}/#{stats.year}"
  end

  def puzzle_url(puzzle)
    "#{BASE}/#{puzzle.year}/day/#{puzzle.day}"
  end

  def input_url(puzzle)
    "#{BASE}/#{puzzle.year}/day/#{puzzle.day}/input"
  end

  def solution_url(puzzle)
    "#{BASE}/#{puzzle.year}/day/#{puzzle.day}/answer"
  end

  def wrap_in_html(content, tag: :article)
    <<~HTML
      <html>
        <head></head>
        <body>
          <main>
            <#{tag}>#{content}</#{tag}>
          </main>
        </body>
      </html>
    HTML
  end
end
