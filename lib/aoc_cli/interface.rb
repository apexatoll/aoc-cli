module AocCli
	module Interface
		class Query
			def initialize
				ARGV.size > 0 ? 
					run(opts:Opts.new.parse_args) : 
					puts(Help.print)
				rescue StandardError => e
					abort e.message
			end
			def run(opts:)
				cmd = Commands.const_get(Validate.cmd(opts.cmd))
					.new(opts.args)
					.exec
				cmd.respond if cmd.class
					.instance_methods.include?(:respond)
			end
		end
		class Help
			def self.print
				require_relative "help.rb"
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
						args[:ans]  = Validate.ans(ARGV.shift)
					when "-S", "--stats"
						@cmd = :StatsTable
					when "-u", "--user"
						args[:user] = ARGV.shift
					when "-U", "--default"
						@cmd = :DefaultAlias
						args[:user] = ARGV.shift
					when "-y", "--init-year"
						@cmd = :YearInit
						args[:year] = Validate.year(ARGV.shift.to_i)
					when "-Y", "--year"
						args[:year] = ARGV.shift.to_i
					else raise E::FlagInv
					end 
				end
				self
			end
		end
		class Validate
			def self.cmd(cmd)
				raise E::CmdNil if cmd.nil?
				cmd
			end
			def self.user(user)
				raise E::UserNil if user.nil?
				raise E::UserInv.new(user) unless user_in_config?(user)
				user
			end
			def self.set_user(user)
				raise E::UserNil if user.nil?
				raise E::UserDup.new(user) if user_in_config?(user)
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
				raise E::KeyDup.new(key) if Files::Config::Tools
					.is_set?(val:"#{key}(\b|$)")
				raise E::KeyInv unless valid_key?(key)
				key
			end
			def self.key(key)
				raise E::KeyNil if key.nil?
				raise E::KeyInv unless valid_key?(key)
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
			def self.no_config
				raise E::ConfigExist if File.exist?(Paths::Config.path)
				Paths::Config.path
			end
			private
			def self.valid_key?(key)
				/session=(?:[a-f0-9]){96}/.match?(key)
			end
			def self.user_in_config?(user)
				Files::Config::Tools.is_set?(key:"cookie=>#{user}")
			end
		end
	end 
end
