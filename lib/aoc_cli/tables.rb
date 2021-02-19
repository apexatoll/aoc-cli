require 'aoc_cli'
module AocCli
	module Tables
		class Attempts
			require 'terminal-table'
			attr_reader :user, :year, :day, :part, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part))
				@user = Validate.user(u)
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@part = Validate.part(p)
				@db   = Database::Query
					.new(path:Paths::Database.cfg(user))
			end
			def show
				puts rows.count > 0 ? table : 
					"You have not attempted this puzzle yet!"
			end
			private
			def table
				tab = Terminal::Table.new(
					:headings  => headings,
					:rows      => rows,
					:title     => title)
				tab.style = {
					:border    => :unicode, 
					:alignment => :center}
				tab
			end
			def title
				"#{year} - Day #{day}:#{part}".bold
			end
			def headings
				["Answer", "Time", "Hint"]
			end
			def rows
				@rows ||= attempts
					.map{|a| [parse_ans(a), parse_time(a), parse_hint(a)]}
			end
			def attempts 
				db.select(
					t:"attempts", 
					cols:"time, answer, high, low, correct", 
					where:{year:year, day:day, part:part})
			end
			def parse_ans(attempt)
				attempt[4] == 1 ? 
					attempt[1].to_s.green :
					attempt[1].to_s.red
			end
			def parse_time(attempt)
				DateTime
					.strptime(attempt[0], "%Y-%m-%d %H:%M:%S %Z")
					.strftime("%H:%M - %d/%m/%y")
			end
			def parse_hint(attempt)
				attempt[2] == 1 ? "low" : 
				attempt[3] == 1 ? "high" : "-"
			end
		end
		module Stats
			class Year
				attr_reader :user, :year, :db
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year))
					@user = Validate.user(u)
					@year = Validate.year(y)
					@db = Database::Query
						.new(path:Paths::Database.cfg(user))
				end
				def print
					puts rows.count > 0 ? table : 
						"You have not completed any puzzles yet"
				end
				def rows
					@rows ||= stats.map{|s| [s[0], s[1], s[2], s[3]]}
				end
				def table
					tab = Terminal::Table.new(
						:headings  => headings,
						:rows      => rows,
						:title     => title)
					tab.style = {
						:border    => :unicode, 
						:alignment => :center}
					tab
				end
				def title
					"Year #{year}"
				end
				def headings
					["Day", "Part", "Attempts", "Time (h:m:s)"]
				end
				def stats
					@stats ||= db.select(
						t:"stats", 
						cols:"day, part, attempts, elapsed",
						where:where)
				end
				def where
					{year:"'#{year}'",
					 correct:"'1'"}
				end
			end
			class Day < Year
				attr_reader :day
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year), 
							   d:Metafile.get(:day))
					super(u:u, y:y)
					@day = Validate.day(d)
				end
				def rows
					@rows ||= stats.map{|s| [s[0], s[1], s[2]]}
				end
				def title
					"Year #{year}: Day #{day}"
				end
				def headings
					["Part", "Attempts", "Time (h:m:s)"]
				end
				def stats
					@stats ||= db.select(
						t:"stats", 
						cols:"part, attempts, elapsed",
						where:where)
				end
				def where
					{year:"'#{year}'",
					  day:"'#{day}'",
					 correct:"'1'"}
				end
			end
		end
		class Calendar
			attr_reader :user, :year, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year))
				@user = Validate.user(u)
				@year = Validate.year(y)
				@db   = Database::Query
					.new(path:Paths::Database.cfg(user))
			end
			def rows
				@rows ||= stars.map{|s| [s[1], parse_stars(s[2])]}
			end
			def print
				puts table
			end
			def table
				tab = Terminal::Table.new(
					:rows      => rows,
					:title     => title)
				tab.style = {
					:border    => :unicode, 
					:alignment => :center}
				tab
			end
			def title
				"#{user}: #{year}"
			end
			def parse_stars(day)
				day.to_i == 0 ?
					".." : ("*" * day.to_i).ljust(2, ".")
			end
			def stars
				@stars ||= db.select(t:"calendar", where:{year:year})
			end
		end
	end
end
#AocCli::Tables::Calendar.new(u: "google", y: 2019).print
