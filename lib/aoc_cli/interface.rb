module AocCli
	module Interface
		class Query
			def initialize
				ARGV.size > 0 ? 
					run(args:Args.new.parse) : Help.print
				rescue StandardError => e
					abort e.message
			end
			def run(args:)
				cmd = Commands.const_get(Validate.cmd(args.cmd))
					.new(args.args).exec
				cmd.respond if cmd.class
					.instance_methods.include?(:respond)
			end
		end
		class Help
			def self.print
				require_relative "help.rb"
			end
		end
		class Args
			attr_reader :cmd, :args
			def initialize
				@args = {}
			end
			def parse
				while ARGV.size > 0
					case ARGV.shift
					when "-a", "--attempts"
						@cmd = :AttemptsTable
					when "-B", "--browser"
						@cmd = :OpenReddit
						args[:browser] = true
					when "-c", "--simple-cal"
						@cmd = :CalendarTable
					when "-C", "--fancy-cal"
						@cmd = :PrintCal
					when "-d", "--init-day"
						@cmd = :DayInit
						args[:day]  = Validate.day(ARGV.shift.to_i)
					when "-D", "--day"
						args[:day]  = ARGV.shift.to_i
					when "-G", "--gen-config"
						@cmd = :GenerateConfig
					when "-h", "--help"
						exit Help.print
					when "-k", "--key"
						@cmd = :KeyStore
						args[:key]  = Validate.set_key(ARGV.shift)
					when "-p", "--part"
						args[:part] = ARGV.shift.to_i
					when "-r", "--refresh"
						@cmd = :Refresh
					when "-R", "--reddit"
						@cmd = :OpenReddit
					when "-s", "--solve"
						@cmd = :DaySolve
						args[:ans]  = ARGV.shift
					when "-S", "--stats"
						@cmd = :StatsTable
					when "-u", "--user"
						args[:user] = ARGV.shift
					when "-U", "--default"
						@cmd = :DefaultAlias
						args[:user] = ARGV.shift
					when "-v", "--version"
						abort "aoc-cli(#{VERSION})"
					when "-y", "--init-year"
						@cmd = :YearInit
						args[:year] = Validate.year(ARGV.shift.to_i)
					when "-Y", "--year"
						args[:year] = ARGV.shift.to_i
					else raise Errors::FlagInv
					end 
				end
				self
			end
		end
	end 
end
