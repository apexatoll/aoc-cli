require 'colorize'
require 'sqlite3'

require_relative 'aoc_cli/errors'
require_relative 'aoc_cli/interface'
require_relative "aoc_cli/version"
require_relative 'aoc_cli/files'
require_relative 'aoc_cli/commands'
require_relative 'aoc_cli/tools'
require_relative 'aoc_cli/year'
require_relative 'aoc_cli/day'
require_relative 'aoc_cli/solve'
require_relative 'aoc_cli/database'
require_relative 'aoc_cli/paths'
require_relative 'aoc_cli/tables'

module AocCli
	Metafile = AocCli::Files::Metafile
	Prefs    = AocCli::Files::Config::Prefs
	Validate = AocCli::Interface::Validate
	E = AocCli::Errors
end
