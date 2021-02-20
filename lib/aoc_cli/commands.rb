module AocCli
	module Commands
		class KeyStore
			attr_reader :user, :key
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @key = args[:user], args[:key]
			end
			def exec
				Files::Config::Cookie.store(user:user, key:key)
				self
			end
			def respond
				puts "Key added successfully"
			end
			def defaults
				{ user:Prefs.default_alias }
			end
		end
		class YearInit
			attr_reader :user, :year, :git
			def initialize(args)
				args = defaults.merge(args).compact
				@user, @year, @git = args[:user], args[:year], args[:git]
			end
			def exec
				Year::Meta.new(u:user, y:year).write
				Year::Progress.new(u:user, y:year).write.init_calendar_db
				Year::GitWrap.new if git
				self
			end
			def respond
				puts "Year #{year} initialised"
			end
			def defaults
				{ user:Prefs.default_alias,
				   git:Prefs.bool(key:"init_git") }
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
				Day::Init.new(u:user, y:year, d:day).mkdir.meta
				Day::Pages.new(u:user, y:year, d:day).load
				self
			end
			def defaults
				{ user:Metafile.get(:user), 
				  year:Metafile.get(:year) }
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
				Tools::Reddit.new(y:year, d:day, b:browser).open
				self
			end
			def defaults
				{ year:Metafile.get(:year),
				  day:Metafile.get(:day),
				  browser:Prefs.bool(key:"reddit_in_browser") }
			end
		end
		class DefaultAlias
			attr_reader :user, :mode
			def initialize(args)
				@user = args[:user]
				@mode = user.nil? ? :get : :set
			end
			def exec
				set if mode == :set && alias_valid
				self
			end
			def respond
				case mode
				when :get then current
				when :set then update end
			end
			private
			def set
				Files::Config::Tools
					.mod_line(key:"default", val:Validate.user(user)) 
			end
			def current
				puts <<~aliases
				Default alias: #{Prefs.default_alias.yellow}
				All aliases: #{Prefs.list_aliases.map{|a| a.blue}
					.join(", ")}
				aliases
			end
			def alias_valid
				Validate.key(Files::Config::Cookie.key(user:user))
			end
			def update
				puts "Default alias changed to: #{user.yellow}"
			end
		end
		class Refresh
			def exec
				case Metafile.type
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
				Tables::Attempts.new(u:user, y:year, d:day, p:part).print
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
				Tables::Calendar.new(u:user, y:year).print
			end
			def defaults
				{ user:Metafile.get(:user),
				  year:Metafile.get(:year) }
			end
		end
		class PrintCal
			attr_reader :path, :year
			def initialize(args)
				args  = defaults.merge(args).compact
				@year = Validate.year(args[:year])
			end
			def path
				case Metafile.type
				when :DAY  then "../#{year}.md"
				when :ROOT then "#{year}.md"
				end
			end
			def exec
				Prefs.bool(key:"calendar_file") ?
					system("cat #{path} | less") :
					puts("You have disabled calendar files")
			end
			def defaults
				{year:Metafile.get(:year)}
			end
		end
		class GenerateConfig
			def initialize(args) end
			def exec
				Files::Config::Example.write
				self
			end
			def respond
				puts "Default config written to #{Paths::Config.path.blue}"
			end
		end
	end
end
