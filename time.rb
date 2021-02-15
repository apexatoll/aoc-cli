require 'date'
require 'time'
require 'sqlite3'
#time1 = DateTime.strptime("1996-07-20 20:08:01 +0000", 
						  #"%Y-%m-%d %H:%M:%S %Z")

time1 = Time.parse("1996-07-20 20:08:01 +0000")
					#.strptime(attempt[0], "%Y-%m-%d %H:%M:%S %Z")

#time2 = 

	elapsed = Time.now - time1
#puts elapsed
#puts time2
#puts time1, time2
#
db = SQLite3::Database.open(Dir.home + "/.config/aoc-cli/db/attempts.db")
rows = db.execute("select time from test").flatten.first

time3 = (Time.now - Time.parse(rows))

def parse_time(time)
	days  = (time / (3600 * 24)).to_i
	hours = ((time - days * 3600 * 24) / 3600).to_i
	mins  = ((time - hours * 3600) / 60).to_i
	secs  = ((time - mins * 60) / 60 ).to_i
	puts days
	puts hours
	puts mins
	puts secs
end


def parse time
	#Time.now 
	[time / 3600,  time / 60 % 60, time % 60].map{|t| t.to_i.to_s.rjust(2, "0")}.join(":")
end


puts parse time3
