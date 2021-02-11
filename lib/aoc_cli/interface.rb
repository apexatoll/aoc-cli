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
			case  ARGV.shift
			when "-k", "--key" then
				@cmd = :KeyStore
				args[:key]  = Val.set?(k: :k, v:ARGV.shift)
			when "-y", "--year"
				@cmd = :YearInit
				args[:year] = Val.year(ARGV.shift.to_i)
			when "-u", "--user"
				args[:user] = Val.val?(k: :u, v:ARGV.shift)
			when "-d", "--day"
				@cmd = :DayInit
				args[:day]  = Val.day(ARGV.shift.to_i)
			when "-s", "--solve"
				@cmd = :DaySolve
				args[:ans]  = Val.set?(k: :a, v:ARGV.shift)
			when "-p", "--part"
				args[:part] = Val.part(ARGV.shift.to_i)
			when "-r", "--reddit"
			#when "--default"
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
end end
