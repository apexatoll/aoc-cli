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
			{user:Files::Config.new.def_acc}
		end
	end
	class YearInit
		attr_reader :user, :year
		def initialize(args)
			args = defaults.merge(args).compact
			@user, @year = args[:user], args[:year]
		end
		def exec
			Year::Meta
				.new(user:user, year:year)
				.write
			Year::Calendar
				.new(user:user, year:year)
				.write.update_meta
			self
		end
		def respond
			puts "Year initialised"
		end
		def defaults
			{user:Files::Config.new.def_acc}
		end
	end
	class DayInit
		attr_reader :user, :year, :day
		def initialize(args)
			args  = defaults.merge(args).compact
			@user = args[:user]
			@year = args[:year]
			@day  = args[:day]
		end
		def exec
			Day::Init
				.new(user:user, year:year, day:day)
				.mkdir.write
			Day::DayFiles
				.new(user:user, year:year, day:day)
				.write
			self
		end
		def defaults
			{user:Mf.get(:user), year:Mf.get(:year)}
		end
		def respond
			puts "Day #{day} initialised"
		end
	end
	class DaySolve
		attr_reader :user, :year, :day, :part, :answer
		def initialize(args)
			args  = defaults.merge(args).compact
			@user = args[:user]
			@year = args[:year]
			@day  = args[:day]
			@part = args[:part]
			@answer = args[:ans]
		end
		def exec 
			Solve::Solve
				.new(user:user, year:year, day:day,  
					 part:part, answer:answer)
				.respond
			self
		end
		def respond
			"REsponse"
		end
		def defaults
			{user:Mf.get(:user), year:Mf.get(:year),
			  day:Mf.get(:day),  part:Mf.get(:part)}
		end
	end
	class OpenReddit
		attr_reader :year, :day
		def initialize(args)
			puts args
			args  = defaults.merge(args).compact
			puts args
			@year = args[:year]
			@day  = args[:day]
		end
		def exec
			Day::Reddit.new(year:year, day:day).open
		end
		def defaults
			{year:Mf.get(:year), day:Mf.get(:day)}
		end
	end
end end
