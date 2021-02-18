module AocCli
	module Commands
		class KeyStore
			attr_reader :user, :key
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @key = args[:user], args[:key]
			end
			def exec
				Files::Cookie.new(u:user).store(key:key)
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
					.new(u:user, y:year)
					.write
				Year::Stars
					.new(u:user, y:year)
					.write.update_meta
				self
			end
			def respond
				puts "Year #{year} initialised"
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
					.new(u:user, y:year, d:day)
					.mkdir
					.meta
				Day::Pages
					.new(u:user, y:year, d:day)
					.write
				self
			end
			def defaults
				{user:Metafile.get(:user), 
				 year:Metafile.get(:year)}
			end
			def respond
				puts "Day #{day} initialised"
			end
		end
		class DaySolve
			attr_reader :user, :year, :day, :part, :ans
			def initialize(args)
				args  = defaults.merge(args).compact
				@user = args[:user]
				@year = args[:year]
				@day  = args[:day]
				@part = args[:part]
				@ans  = args[:ans]
			end
			def exec 
				Solve::Attempt
					.new(u:user, y:year, d:day, p:part, a:ans)
					.respond
				self
			end
			def defaults
				{user:Metafile.get(:user),
				 year:Metafile.get(:year),
				  day:Metafile.get(:day),
				 part:Metafile.get(:part)}
			end
		end
		class OpenReddit
			attr_reader :year, :day, :browser
			def initialize(args)
				args  = defaults.merge(args).compact
				@year = Validate.year(args[:year])
				@day  = Validate.day(args[:day])
				@browser = args[:browser]
			end
			def exec
				Day::Reddit.new(y:year, d:day, b:browser).open
				self
			end
			def defaults
				{year:Metafile.get(:year),
				 day:Metafile.get(:day),
				 browser:Files::Config
					.new.get_bool(key:"browser")}
			end
		end
		class DefaultUser
			attr_reader :user, :mode
			def initialize(args)
				@user = args[:user]
				@mode = user.nil? ? :get : :set
			end
			def exec
				case mode
				when :get then get_default
				when :set then set_default end
				self
			end
			def get_default
				puts "Current default alias: "\
					 "#{(Files::Config.new
						.get_line(key:"default") || "main")
						.to_s.yellow}"
			end
			def set_default
				Files::Config.new.mod_line(
					key:"default", 
					val:Validate.user(user))
				puts "Default account succesfully changed to "\
					 "#{user.yellow}"
			end
		end
		class DefaultReddit
			attr_reader :value, :mode
			def initialize(args)
				@value = args[:value]
				@mode = value.nil? ? :get : :set
			end
			def exec
				case mode
				when :get then get_default
				when :set then set_default
				end
			end
			def get_default
				puts "Always open Reddit in browser? "\
					 "#{Files::Config.new
						.get_bool(key:"browser")
						.to_s.yellow}"
			end
			def set_default
				Files::Config.new.mod_line(
					key:"browser", val:value)
				puts "Reddit browser setting changed to "\
					 "#{value.yellow}"
			end
		end
		class Refresh
			attr_reader :dir
			def initialize(args)
				@dir = Metafile.type
			end
			def exec
				case dir
				when :DAY  then Day.refresh
				when :ROOT then Year.refresh end
				self
			end
		end
		class AttemptsTable
			attr_reader :user, :year, :day, :part
			def initialize(args)
				args = defaults.merge(args).compact
				@user = args[:user]
				@year = args[:year]
				@day  = args[:day]
				@part = args[:part]
			end
			def exec
				Tables::Attempts
					.new(u:user, y:year, d:day, p:part).show
				self
			end
			def defaults
				{user:Metafile.get(:user),
				 year:Metafile.get(:year),
				  day:Metafile.get(:day),
				 part:Metafile.get(:part)}
			end
		end
		class StatsTable
			attr_reader :user, :year, :day
			def initialize(args)
				args = defaults.merge(args).compact
				@user = args[:user]
				@year = args[:year]
				@day  = args[:day]
			end
			def exec
				day.nil? ?
					Tables::Stats::Year.new(u:user, y:year).print :
					Tables::Stats::Day.new(u:user, y:year, d:day).print
			end
			def defaults
				{ user:Metafile.get(:user),
				  year:Metafile.get(:year),
				   day:Metafile.get(:day) }
			end
		end
		class CalendarTable
			attr_reader :user, :year
			def initialize(args)
				args = defaults.merge(args).compact
				@user = Validate.user(args[:user])
				@year = Validate.year(args[:year])
			end
			def exec
				Tables::Calendar
					.new(u:user, y:year)
					.print
			end
			def defaults
				{ user:Metafile.get(:user),
				  year:Metafile.get(:year) }
			end
		end
	end
end
