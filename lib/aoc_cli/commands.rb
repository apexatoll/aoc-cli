module AocCli
	module Commands
		class KeyStore
			attr_reader :user, :key
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @key = args[:user], args[:key]
			end
			def exec
				Files::Cookie.new(user:user).store(key:key)
				self
			end
			def respond
				puts "Key added successfully"
			end
			def defaults
				{user:"main"}
			end
		end
		class YearInit
			attr_reader :user, :year
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @year = args[:user], args[:year]
			end
			def exec
				Year::Meta.new(user:user, year:year).write
				Year::Calendar.new(user:user, year:year).write.update_meta
				self
			end
			def respond
				puts "Year initialised"
			end
			def defaults
				{user:"main"}
			end
		end
		class DayInit
			attr_reader :user, :year, :day
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @year, @day = args[:user], args[:year], args[:day]
			end
			def exec
				Day::Init.new(user:user, year:year, day:day).mkdir.write
				Day::Data::Puzzle.new(user:user, year:year, day:day).write
				Day::Data::Input.new(user:user, year:year, day:day).write
				self
			end
			def defaults
				{user:Files::Metafile.get(:user), year:Files::Metafile.get(:year)}
			end
			def respond
				puts "Day #{day} initialised"
			end
		end
		class DaySolve
			attr_reader :user, :year, :day, :part, :answer
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @year, @day, @part, @answer = args[:user], args[:year], args[:day], args[:part], args[:answer]
			end
			def exec 
				Solve::Solve.new(user:user, year:year, day:day, part:part, answer:answer).respond
				self
			end
			def respond
				"REsponse"
			end
			def all
				{user:user, day: day, year:year, part:part, answer:answer}
			end
			def defaults
				{user:Files::Metafile.get(:user), 
				 year:Files::Metafile.get(:year),
				  day:Files::Metafile.get(:day),
				 part:Files::Metafile.get(:part)}
			end
		end
	end
end
