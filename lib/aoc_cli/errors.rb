module AocCli
	module Errors
		ERROR = "Error".bold.red
		class UserNil < StandardError
			def message
				<<~error
				#{ERROR}: No user alias value.
				Specify an alias to use when passing the #{"-u".yellow} or #{"--user".yellow} flag
				error
			end
		end
		class UserInv < StandardError
			def initialize(user)
				@user = user
			end
			def message
				<<~error
				#{ERROR}: Invalid user: #{@user.to_s.red}
				No key was found under this alias
				error
			end
		end
		class UserDup < StandardError
			attr_reader :user
			def initialize(user)
				@user = user
			end
			def message
				<<~error
				#{ERROR}: There is already a key set for the user #{user.yellow}
				Either check your config file or set a new username for this key using the #{"-u".yellow} or #{"--user".yellow} flags
				error
			end
		end
		class YearNil < StandardError
			def message
				<<~error
				#{ERROR}: No year value.
				Set the year using the #{"-y".yellow} or #{"--year".yellow} flags.
				error
			end
		end
		class YearInv < StandardError
			attr_reader :year
			def initialize(year)
				@year = year
			end
			def message
				<<~error
				#{ERROR}: Invalid year: #{year.to_s.red}
				Advent of Code currently spans 2015 - 2020.
				error
			end
		end
		class DayNil < StandardError
			def message
				<<~error
				#{ERROR}: No day value.
				Specify the day using the #{"-d".yellow} or #{"--day".yellow} flags.
				error
			end
		end
		class DayInv < StandardError
			def initialize(day)
				@day = day
			end
			def message
				<<~error
				#{ERROR}: Invalid day: #{@day.to_s.red}
				Valid days are between 1 and 25
				error
			end
		end
		class DayExist < StandardError
			def initialize(day)
				@day = day.to_s
			end
			def message
				<<~error
				#{ERROR}: Day #{@day.red} is already initialised!
				error
			end
		end
		class PartNil < StandardError
			def message
				<<~error
				#{ERROR}: No part value.
				Check the .meta file or pass it manually with the #{"-p".yellow} or #{"--part".yellow} flags
				error
			end
		end
		class PartInv < StandardError
			attr_reader :part
			def initialize(part)
				@part = part
			end
			def message
				<<~error
				#{ERROR}: Invalid part: #{part.red}
				Part refers to the part of the puzzle and can either be 1 or 2.
				error
			end
		end
		class AnsNil < StandardError
			def message
				<<~error
				#{ERROR}: No answer value.
				error
			end
		end
		class KeyNil < StandardError
			def message
				<<~error
				#{ERROR}: No session key value.
				Use the #{"-k".yellow} or #{"--key".yellow} flags to store the key
				error
			end
		end
		class KeyDup < StandardError
			attr_reader :key
			def initialize(key)
				@key = key
			end
			def message
				<<~error
				#{ERROR}: The key #{key.yellow} already exists in your config file
				error
			end
		end
		class AlrInit < StandardError
			def message
				<<~error
				#{ERROR}: This directory is already initialised.
				error
			end
		end
		class NotInit < StandardError
			def message
				<<~error
				#{ERROR}: You must initialise the directory first
				error
			end
		end
		class PuzzComp < StandardError
			def message
				<<~error
				#{ERROR}: This puzzle is already complete!
				error
			end
		end
		class FlagInv < StandardError
			attr_reader :flag
			def initialize(flag)
				@flag = flag
			end
			def message
				<<~error
				#{ERROR}: Invalid flag: #{flag.red}
				Use the #{"-h".yellow} or #{"--help".yellow} flags for a list of commands
				error
			end
		end
		class CmdNil < StandardError
			def message
				<<~error
				#{ERROR}: Flags passed but no command specified
				error
			end
		end
		class KeyInv < StandardError
			def message
				<<~error
				#{ERROR}: Invalid key
				Double check your session key. It should start with "session=" 
				error
			end
		end
		class ConfigExist < StandardError
			def message
				<<~error
				#{ERROR}: A config file already exists in #{Paths::Config.path.blue}
				error
			end
		end
		class AtmptDup < StandardError
			attr_reader :answer
			def initialize(answer)
				@answer = answer
			end
			def message
				<<~error
				#{ERROR}: You have already tried #{answer.red}
				To see previous attempts run #{"aoc -a".yellow}
				error
			end
		end
	end 
	class Validate
		E = Errors
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
				year.to_i > 2021
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
		def self.ans(attempt:, ans:)
			raise E::AnsNil if ans.nil?
			raise E::AtmptDup.new(ans) if Database::Attempt
				.new(attempt:attempt).duplicate?(ans:ans)
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
