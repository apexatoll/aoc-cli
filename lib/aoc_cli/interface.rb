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
				cmd = Object
					.const_get("AocCli::Commands::#{opts.cmd}")
					.new(opts.args)
					.exec
				cmd.respond if cmd.class.instance_methods.include?(:respond)
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
					when "-b", "--browser"
						args[:browser] = true
					when "-c", "--calendar"
						@cmd = :CalendarTable
					when "-d", "--init-day"
						@cmd = :DayInit
						args[:day]  = Validate.day(ARGV.shift.to_i)
					when "-h", "--help"
						exit Help.print
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
				raise E::UserInv.new(user) unless user_in_config?(user)
				user
			end
			def self.set_user(user)
				raise E::UserNil if user.nil?
				raise E::UserDup if user_in_config?(user)
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
				raise E::KeyDup.new(key) if Files::Config.new.is_set?(val:key)
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
			private
			def self.valid_key?(key)
				/session=(?:[a-f0-9]){96}/.match?(key)
			end
			def self.user_in_config?(user)
				Files::Config.new.is_set?(key:"cookie=>#{user}")
			end
		end
	end 
end
