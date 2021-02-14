module AocCli
	module Errors
		ERROR = "Error".bold.red
		class UserNil < StandardError
			def message
				<<~error
				#{ERROR}: The user flag was passed but no user was entered.
				Please specify which alias to use when using the #{"-u".yellow} or #{"--user".yellow} flag
				error
			end
		end
		class UserInv < StandardError
			def initialize(user)
				@user = user
			end
			def message
				<<~error
				#{ERROR}: Invalid user #{@user.to_s.red}
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
		class DayNil < StandardError
			def message
				<<~error
				#{ERROR}: No day passed
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
				#{ERROR}: Invalid day passed #{@day.to_s.red}
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
				#{ERROR}: No part value passed.
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
				#{ERROR}: Invalid part passed: #{part.red}
				Part refers to the part of the puzzle and can either be 1 or 2.
				error
			end
		end
		class AnsNil < StandardError
			def message
				<<~error
				#{ERROR}: No answer passed with the solve flag
				error
			end
		end
		class KeyNil < StandardError
			def message
				<<~error
				#{ERROR}: No session key was specified
				Use the #{"-k".yellow} or #{"--key".yellow} flags
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
			def message
				<<~error
				#{ERROR}: Invalid flag passed
				Use the #{"-h".yellow} or #{"--help".yellow} flags for a list of commands
				error
			end
		end
	end 
end
