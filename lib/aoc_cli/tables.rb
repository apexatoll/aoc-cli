module AocCli
	module Tables
		class Table
			require 'terminal-table'
			attr_reader :user, :year, :table, :cols, :where
			def initialize(u:Metafile.get(:user), y:Metafile.get(:year))
				@user = Validate.user(u)
				@year = Validate.year(y)
			end
			def border
				Prefs.bool(key:"unicode_tables") ? :unicode : :ascii
			end
			def data
				Database::Query
					.new(path:Paths::Database.cfg(user))
					.select(t:table, cols:cols, where:where)
			end
			def print
				puts rows.count > 0 ? make : nil_message
			end
			def make
				tab = Terminal::Table.new(
					:headings  => headings,
					:rows      => rows,
					:title     => title)
				tab.style = {
					:border    => border, 
					:alignment => :center}
				tab
			end
		end
		class Attempts < Table
			attr_reader :day, :part 
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part))
				super(u:u, y:y)
				@day   = Validate.day(d)
				@part  = Validate.part(p)
				@table = :attempts
				@cols  = "time, answer, high, low, correct"
				@where = {year:year, day:day, part:part}
			end
			def title
				"#{year} - Day #{day}:#{part}".bold
			end
			def headings
				["Answer", "Time", "Hint"]
			end
			def rows
				@rows ||= data.map do |d|
					[parse_ans(d), parse_time(d), parse_hint(d)]
				end
			end
			def parse_ans(row)
				row[4] == 1 ?  row[1].to_s.green : row[1].to_s.red
			end
			def parse_time(row)
				DateTime.strptime(row[0], "%Y-%m-%d %H:%M:%S %Z")
					.strftime("%H:%M - %d/%m/%y")
			end
			def parse_hint(row)
				row[3] == 1 ? "low" : 
					row[2] == 1 ? "high" : "-"
			end
			def nil_message
				"You have not attempted part #{part} yet!"
			end
		end
		module Stats
			class Year < Table
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year))
					super(u:u, y:y)
					@table = :stats
					@cols  = "day, part, attempts, elapsed"
					@where = {year:"'#{year}'", correct:"'1'"}
				end
				def title
					"Year #{year}"
				end
				def headings
					["Day", "Part", "Attempts", "Time (h:m:s)"]
				end
				def rows
					@rows ||= data.map{|d| [d[0], d[1], d[2], d[3]]}
				end
				def nil_message
					"You have not completed any puzzles yet"
				end
			end
			class Day < Year
				attr_reader :day
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year), 
							   d:Metafile.get(:day))
					super(u:u, y:y)
					@day = Validate.day(d)
					@cols = "part, attempts, elapsed"
					@where = { year:"'#{year}'", 
							   day:"'#{day}'", 
							   correct:"'1'" }
				end
				def title
					"Year #{year}: Day #{day}"
				end
				def headings
					["Part", "Attempts", "Time (h:m:s)"]
				end
				def rows
					@rows ||= data.map{|d| [d[0], d[1], d[2]]}
				end
			end
		end
		class Calendar < Table
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year))
				super(u:u, y:y)
				@table = :calendar
				@cols  = "*"
				@where = {year:year}
			end
			def title
				"#{user}: #{year}"
			end
			def headings
				["Day", "Stars"]
			end
			def rows
				@rows ||= data.map{|d| [d[1], parse_stars(d[2])]}
			end
			def parse_stars(day)
				day.to_i == 0 ? ".." : ("*" * day.to_i).ljust(2, ".")
			end
		end
	end
end
