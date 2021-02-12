module AocCli
	module Interface
		class Query
			def initialize
				ARGV.size > 0 ? 
					run(opts:Opts.new.parse_args) : 
					puts(Help.print)
			end
			def run(opts:)
				Object.const_get("AocCli::Commands::#{opts.cmd}")
					.new(opts.args)
					.exec.respond
				#rescue StandardError => e
					#abort e.message
			end
		end
		class Help
			def self.title(title)
				"#{title.bold}"
			end
			def self.flag(short, full)
				str = "  #{short.yellow.bold} [#{full.blue.italic}]"
				full.length <= 8 ?
					str += "\t  " :
					str += "  "
				str
			end
			def self.print
				<<~help_screen
				aoc-cli - v0.1.0 2021

				#{title("Usage")}
				#{"  aoc" + " -flag".italic + " value".bold}

				#{title("Setup")}
				 - Store session cookie keys to access AoC
				#{flag("-k", "--key")}Store a session cookie to use the cli.
				#{flag("-u", "--user")}Set alias for key (default: "main")

				#{title("Year directory")}
				 - Initialise a year directory to use aoc-cli.
				 - The -u flag can be used to intiailise with a specific alias
				 - If no alias is passed, the default key is used

				#{flag("-y","--year")}Initialise directory and fetch calendar
				#{flag("-u", "--user")}Specify alias for initialisation
				#{flag("-d","--day")}Create day subdirectory and fetch puzzle and input
				#{flag("-r", "--refresh")}Refresh calendar
				
				#{title("Day subdirectory")}
				 - Solve AoC puzzles
				#{flag("-s", "--solve")}Attempt puzzle
				#{flag("-r", "--refresh")}Refresh puzzle
				#{flag("-R", "--reddit")}Open Reddit solution megathread

				#{title("Configuration")}
				 - Pass with a value to update setting
				 - Pass without an argument to display current setting. 
				 
				#{flag("-C", "--colour")}Use coloured outputs (default: true)
				#{flag("-B", "--browser")}Always open Reddit in browser (default: false)
				#{flag("-U", "--default")}Default key alias to use (default: "main")
				
				Year, day, user and part options for commands are set automatically with metafile information when the year and days are initiailised and commands are run from the appropriate directories. These options can be passed manually for commands (not recommended)
				help_screen
			end
		end
		class Opts
			attr_reader :cmd, :args
			def initialize
				@args = {}
			end
			def parse_args
				while ARGV.size > 0
				case  ARGV.shift
				when "-d", "--init-day"
					@cmd = :DayInit
					args[:day]  = Validate.day(ARGV.shift.to_i)
				when "-D", "--day"
					args[:day]  = Validate.day(ARGV.shift.to_i)
				when "-k", "--key"
					@cmd = :KeyStore
					args[:key]  = Validate.set?(k: :k, v:ARGV.shift)
				when "-p", "--part"
					args[:part] = Validate.part(ARGV.shift.to_i)
				when "-R", "--reddit"
					@cmd = :OpenReddit
				when "-s", "--solve"
					@cmd = :DaySolve
					args[:ans]  = Validate.set?(k: :a, v:ARGV.shift)
				when "-u", "--user"
					args[:user] = Validate.val?(k: :u, v:ARGV.shift)
				when "-U", "--default-user"
					@cmd = :UserDefault
					nil
				when "-y", "--init-year"
					@cmd = :YearInit
					args[:year] = Validate.year(ARGV.shift.to_i)
				when "-Y"
					args[:year] = Validate.year(ARGV.shift.to_i)
				when "-h", "--help"
					abort Help.print
				else raise E::FlagInv
				end end
				self
			end
		end
		class Validate
			def self.year(year)
				raise E::YearNil if year.nil?
				raise E::YearInv.new(year) if year.to_i < 2015 || year.to_i > 2020
				year
			end
			def self.day(day)
				raise E::DayNil if day.nil?
				raise E::DayInv if day.to_i < 1 || day.to_i > 25
				day
			end
			def self.part(part)
				raise E::PartNil  if part.nil?
				raise E::PuzzComp if part.to_i == 3
				raise E::PartInv  if part.to_i < 1 || part.to_i > 2
				part
			end
			def self.set?(k:, v:)
				if v.nil? 
					case k
					when :k then raise E::KeyNil
					when :u then raise E::UserNil
					when :a then raise E::AnsNil
					end 
				else return v end
			end
			def self.set_user(user)
				raise E::UserNil if user.nil?
				raise E::UserDup if Files::Config.new
					.is_set?(key:"cookie=>#{user}")
				user
			end
			def self.get_user(user)
				raise E::UserNil if user.nil?
				raise E::UserInv unless Files::Config.new
					.is_set?(key:"cookie=>#{user}")
				user
			end
			def self.set_key(key)
				raise E::KeyNil if key.nil?
				raise E::KeyDup if Files::Config
					.new.is_set?(val:key)
			end
			def self.get_key(key)
				raise E::KeyNil if key.nil?
				raise E::KeyInv unless Files::Config
					.new.is_set?(val:key)
			end
		end
	end 
end
