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
					.new(path:Paths::Database
					.cfg("attempts"))
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
					.map{|a| [parse_ans(a), parse_time(a),
							  parse_hint(a)]}
			end
			def attempts 
				db.select(
					t:user, 
					cols:"time, answer, high, low, correct", 
					data:{year:year, day:day, part:part})
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
		class StatsYear
			attr_reader :user, :year, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year))
				@user = Validate.user(u)
				@year = Validate.year(y)
				@db = Database::Query
					.new(path:Paths::Database.cfg("#{user}"))
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
				["Day", "Part", "Attempts", "Time"]
			end
			def stats
				@stats ||= db.select(
					t:"stats", 
					cols:"day, part, attempts, elapsed",
					data:where)
			end
			def where
				{year:year,
				 complete:1}
			end
		end
		#class StatsDay
			#def initialize()
			
			#end
			#def print

			#end
		#end
	end
end
#AocCli::Tables::StatsYear.new(u: "test", y: 2019, d: 5, p: 2, attempts: 3)
AocCli::Tables::StatsYear.new(u: "test", y: 2019).print
