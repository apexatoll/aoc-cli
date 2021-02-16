module AocCli
	module Interface
		class Query
			def initialize
				ARGV.size > 0 ? 
					run(opts:Opts.new.parse_args) : 
					puts(Help.print)
				#rescue StandardError => e
					#abort e.message
			end
			def run(opts:)
				cmd = Object
					.const_get("AocCli::Commands::#{opts.cmd}")
					.new(opts.args)
					.exec
				cmd.respond if cmd.class.instance_methods.include?(:respond)
			end
		end
		class Help
			def self.print
			<<~help
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
				help
			end
			def self.title(title)
				"#{title.bold}"
			end
			def self.flag(short, full)
				str = "\t#{short.yellow.bold} [#{full.blue.italic}]"
				full.length <= 8 ?
					str += "\t\t\t  " :
					full.length <= 16 ? 
						str += "\t\t  " : str += "\t  "
				str
			end
		end
		class Opts
			attr_reader :cmd, :args
			def initialize
				@args = {}
			end
			def parse_args
				while ARGV.size > 0
					case ARGV.shift
					when "-a", "--attempts"
						@cmd = :AttemptsTable
					when "-b", "--browser"
						args[:browser] = true
					when "-d", "--init-day"
						@cmd = :DayInit
						args[:day]  = Validate.day(ARGV.shift.to_i)
					when "-h", "--help"
						abort Help.print
					when "-k", "--key"
						@cmd = :KeyStore
						args[:key]  = Validate.set_key(ARGV.shift)
					when "-p", "--part"
						args[:part] = Validate.part(ARGV.shift.to_i)
					when "-r", "--refresh"
						@cmd = :Refresh
					when "-s", "--solve"
						@cmd = :DaySolve
						args[:ans]  = Validate.ans(ARGV.shift)
					when "-u", "--user"
						args[:user] = ARGV.shift
					when "-y", "--init-year"
						@cmd = :YearInit
						args[:year] = Validate.year(ARGV.shift.to_i)
					when "-B", "--browser"
						@cmd = :DefaultReddit
						args[:value] = ARGV.shift
					when "-D", "--day"
						args[:day]  = Validate.day(ARGV.shift.to_i)
					when "-R", "--reddit"
						@cmd = :OpenReddit
					when "-S", "--stats"
						@cmd = :StatsTable
					when "-U", "--default-user"
						@cmd = :DefaultUser
						args[:user] = ARGV.shift
					when "-Y", "--year"
						args[:year] = Validate.year(ARGV.shift.to_i)
					else raise E::FlagInv
					end 
				end
				raise E::NoCmd if cmd.nil?
				self
			end
		end
		class Validate
			def self.user(user)
				raise E::UserNil if user.nil?
				raise E::UserInv.new(user) unless Files::Config
					.new.is_set?(key:"cookie=>#{user}")
				user
			end
			def self.set_user(user)
				raise E::UserNil if user.nil?
				raise E::UserDup if Files::Config.new
					.is_set?(key:"cookie=>#{user}")
				user
			end
			def self.year(year)
				raise E::YearNil if year.nil?
				raise E::YearInv.new(year) if year.to_i < 2015 ||
					year.to_i > 2020
				year
			end
			def self.day(day)
				raise E::DayNil if day.nil? || day == 0
				raise E::DayInv.new(day) if day.to_i < 1 ||
					day.to_i > 25
				day
			end
			def self.part(part)
				raise E::PartNil  if part.nil?
				raise E::PuzzComp if part.to_i == 3
				raise E::PartInv  if part.to_i < 1 || part.to_i > 2
				part
			end
			def self.set_key(key)
				raise E::KeyNil if key.nil?
				raise E::KeyDup if Files::Config
					.new.is_set?(val:key)
				key
			end
			def self.get_key(key)
				raise E::KeyNil if key.nil?
				key
			end
			def self.ans(ans)
				raise E::AnsNil if ans.nil?
				ans
			end
			def self.day_dir(day)
				raise E::DayExist.new(day) if Dir.exist?(day)
				day
			end
			def self.init(dir)
				raise E::NotInit unless File.exist?("#{dir}/.meta")
				dir
			end
			def self.not_init(dir:, year:)
				raise E::AlrInit if File.exist?("#{dir}/.meta") && 
					Metafile.get(:year) != year.to_s
				dir
			end
		end
	end 
end
