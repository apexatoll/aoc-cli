require_relative "lib/aoc_cli/version"

Gem::Specification.new do |spec|
  spec.name    = "aoc_cli"
  spec.version = AocCli::VERSION
  spec.authors = ["Christian Welham"]
  spec.email   = ["welhamm@gmail.com"]
  spec.summary = "A command-line interface for the Advent of Code puzzles"
  spec.description = "A command-line interface for the Advent of Code puzzles. Features include downloading puzzles and inputs, solving puzzles and tracking year progress from within the terminal"
  spec.homepage = "https://github.com/apexatoll/aoc-cli"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/apexatoll/aoc-cli"
  spec.metadata["changelog_uri"] = "https://github.com/apexatoll/aoc-cli/CHANGELOG.md"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject{|f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "bin"
  spec.executables << 'aoc'
  spec.require_paths = ["lib"]
  spec.add_dependency("colorize")
  spec.add_dependency("curb")
  spec.add_dependency("git")
  spec.add_dependency("pandoc-ruby")
  spec.add_dependency("sqlite3")
  spec.add_dependency("terminal-table", "~> 3.0.0")
end
