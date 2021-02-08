# frozen_string_literal: true
require_relative "lib/aoc_cli/version"

Gem::Specification.new do |spec|
  spec.name = "aoc_cli"
  spec.version = AocCli::VERSION
  spec.authors = ["Christian Welham"]
  spec.email = ["welhamm@gmail.com"]
  spec.summary = "A command-line interface for the Advent of Code puzzles"
  spec.description = "A command-line interface for the Advent of Code puzzles. Features include downloading puzzles and inputs, solving puzzles and tracking year progress from within the terminal"
  #spec.homepage = ""
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables << 'aoc'
  #spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
