module AocCli
	module Errors
		ERROR = "Error".bold.red
		class KeyNil < StandardError
			def message
				<<~error
				#{ERROR}: No session key was specified
				Use the #{"-k".yellow} or #{"--key".yellow} flags
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
				Either check your config file or set a new username for this key using
				the #{"-u".yellow} or #{"--user".yellow} flags
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
				#{ERROR}: The key #{user.yellow} already exists in your config file
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
		class YearNil < StandardError
			def message
				<<~error
				#{ERROR}: No year specified to initialise.
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
				#{ERROR}: Invalid year passed #{year.to_s.red}
				Advent of Code currently spans 2015 - 2020.
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
		class FlagInv < StandardError
			def message
				<<~error
				#{ERROR}: Invalid flag passed
				Use the #{"-h".yellow} or #{"--help".yellow} flags for a list of commands
				error
			end
		end
		class KeyNot < StandardError
			attr_reader :user
			def initialize(user)
				@user = user
			end
			def message
				<<~error
				#{ERROR}: No key was found for the user #{user.yellow}
				Try setting a key with the #{"-k".yellow} or #{"--key".yelow} flags.
				error
			end
		end
		class RootNot < StandardError
			def message
				<<~error
				#{ERROR}: You cannot perform that action here
				Are you sure you are in the year directory?
				error
			end
		end
	end
end
