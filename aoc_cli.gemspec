require_relative "lib/aoc_cli/version"

Gem::Specification.new do |spec|
  spec.name    = "aoc_cli"
  spec.version = AocCli::VERSION
  spec.authors = ["Christian Welham"]
  spec.email   = ["welhamm@gmail.com"]

  spec.summary = "A command-line interface for the Advent of Code puzzles"

  spec.description = <<~DESCRIPTION
    A command-line interface for the Advent of Code puzzles. Features include \
    downloading puzzles and inputs, solving puzzles and tracking year progress \
    from within the terminal
  DESCRIPTION

  spec.homepage = "https://github.com/apexatoll/aoc-cli"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/apexatoll/aoc-cli"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f == __FILE__ || f.match?(/\A(bin|spec|\.git)/)
    end
  end

  spec.bindir = "exe"
  spec.executables = ["aoc"]
  spec.require_paths = %w[lib db]

  spec.add_dependency "http"
  spec.add_dependency "kangaru"
  spec.add_dependency "nokogiri"
  spec.add_dependency "reverse_markdown"
  spec.add_dependency "sequel_polymorphic"
  spec.add_dependency "terminal-table"
end
