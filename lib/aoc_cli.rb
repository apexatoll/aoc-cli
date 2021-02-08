require 'colorize'
require 'json'
require_relative "aoc_cli/version"
require_relative 'aoc_cli/commands.rb'
require_relative 'aoc_cli/errors.rb'
require_relative 'aoc_cli/tools.rb'
require_relative 'aoc_cli/files.rb'
require_relative 'aoc_cli/year.rb'
require_relative 'aoc_cli/day.rb'
require_relative 'aoc_cli/solve.rb'

module AocCli
	module Interface
		class Query
			def initialize
				ARGV.size > 0 ? 
					run(opts:Opts.new.parse) : 
					puts(help)
			end
			def run(opts:)
				Object.const_get("AocCli::Commands::#{opts.cmd}")
					.new(opts.args)
					.exec.respond
				#rescue StandardError => e
					#abort e.message
			end
			def help
				<<~help_screen
				Here is the help screen
				help_screen
			end
		end
		class Opts
			attr_reader :cmd, :args
			def initialize
				@args = {}
			end
			def parse
				while ARGV.size > 0
					case ARGV.shift
					when "-k", "--key"
						@cmd = :KeyStore
						args[:key]  = Validate.val?(k: :key, v:ARGV.shift)
					when "-y", "--year"
						@cmd = :YearInit
						args[:year] = Validate.year(ARGV.shift.to_i)
					when "-u", "--user"
						args[:user] = Validate.val?(k: :user,v:ARGV.shift)
					when "-d", "--day"
						@cmd = :DayInit
						args[:day]  = Validate.day(ARGV.shift.to_i)
					when "-s", "--solve"
						@cmd = :DaySolve
						args[:answer] = Validate.val?(k: :answer, v:ARGV.shift)
					when "-p", "--part"
						args[:part] = Validate.part(ARGV.shift.to_i)
					when "-r", "--refresh"
					else raise Errors::FlagInv
					end
				end
				self
			end
		end
		class Validate
			def self.year(year)
				raise Errors::YearNil if year.nil?
				raise Errors::YearInv.new(year) if year.to_i < 2015 || year.to_i > 2020
				year
			end
			def self.day(day)
				raise Errors::DayNil if day.nil?
				raise Errors::DayInv if day.to_i < 1 || day.to_i > 25
				day
			end
			def self.part(part)
			end
			def self.val?(k:, v:)
				if v.nil? 
					case k
					when :key then raise Errors::KeyNil
					when :user then raise Errors::UserNil
					end 
				else v 
				end
			end
		end
	end
end
