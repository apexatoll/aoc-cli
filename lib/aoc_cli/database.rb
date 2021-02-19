#require 'aoc_cli'
module AocCli
	module Database
		class Query
			require 'sqlite3'
			attr_reader :db
			def initialize(path:)
				@db = SQLite3::Database.open(path)
			end
			def select(t:, cols:"*", where:)
				db.execute(
				"SELECT #{cols} FROM #{t} "\
				"WHERE #{where.map{|k, v| "#{k} = #{v}"}.join(" AND ")}")
			end
			def table(t:, cols:)
				db.execute(
				"CREATE TABLE IF NOT EXISTS "\
				"#{t}(#{cols.map{|c, t| "#{c} #{t}"}.join(", ")})")
				self
			end
			def insert(t:, val:)
				db.execute(
				"INSERT INTO #{t} "\
				"VALUES(#{val.join(", ")})")
				self
			end
			def update(t:, val:, where:)
				db.execute(
				"UPDATE #{t} "\
				"SET #{val.map{|c, v| "#{c} = #{v}"}.join(", ")} "\
				"WHERE #{where.map{|c, v| "#{c} = #{v}"}.join(" AND ")}")
				self
			end
		end
		class Log
			attr_reader :attempt, :db
			def initialize(attempt:)
				@attempt = attempt
				@db = Query.new(path:Paths::Database
					.cfg("#{attempt.user}"))
					.table(t:"attempts", cols:cols)
			end
			def correct
				db.insert(t:"attempts", val:data << 1 << 0 << 0)
				self
			end
			def incorrect(high:, low:)
				db.insert(t:"attempts", val:data.push(0)
					.push(parse_hint(high:high, low:low)))
				self
			end
			def parse_hint(high:, low:)
				[ high ? 1 : 0, low ? 1 : 0 ]
			end
			def data
				[ "'#{Time.now}'",
				  "'#{attempt.year}'",
				  "'#{attempt.day}'",
				  "'#{attempt.part}'",
				  "'#{attempt.answer}'" ]
			end
			def cols
				{ time: :TEXT, 
				  year: :INT, 
				  day: :INT, 
				  part: :INT, 
				  answer: :TEXT, 
				  correct: :INT,
				  low: :INT,
				  high: :INT }
			end
			def count_attempts
				db.select(t:"attempts", where:where).count
			end
			def where
				{ year:attempt.year,
				  day:attempt.day,
				  part:attempt.part }
			end
		end
		module Stats
			class Init
				attr_reader :user, :year, :day, :part, :now, :db
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year),
							   d:Metafile.get(:day),
							   p:Metafile.get(:part))
					@user = Validate.user(u)
					@year = Validate.year(y)
					@day  = Validate.day(d)
					@part = p
					@now  = Time.now
					@db   = Query.new(path:Paths::Database.cfg(user))
							 .table(t:"stats", cols:cols)
				end
				def cols
					{ year: :INT, 
					  day: :INT, 
					  part: :INT, 
					  dl_time: :TEXT,
					  end_time: :TEXT,
					  elapsed: :TEXT,
					  attempts: :INT,
					  correct: :INT }
				end
				def init
					db.insert(t:"stats", val:data)
				end
				def data
					[ "'#{year}'",
					  "'#{day}'",
					  "'#{part}'",
					  "'#{now}'",
					  "NULL",
					  "NULL",
					  "'0'",
					  "'0'" ]
				end
			end
			class Complete < Init
				attr_reader :n_attempts
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year),
							   d:Metafile.get(:day),
							   p:Metafile.get(:part),
							   n:)
					super(u:u, y:y, d:d, p:p)
					@n_attempts = n
				end
				def update
					db.update(t:"stats", val:val, where:where)
				end
				def val
					{ elapsed:  "'#{elapsed}'", 
					  end_time: "'#{now}'", 
					  attempts: "'#{n_attempts}'",
					  correct:  "'1'" }
				end
				def where
					{ year: year,
					  day:  day, 
					  part: part }
				end
				def elapsed
					@elapsed ||= hms(now - dl_time)
				end
				def hms(seconds)
					[seconds/3600, seconds/60 % 60, seconds % 60]
						.map{|t| t.to_i.to_s.rjust(2, "0")}.join(":")
				end
				def dl_time
					@dl_time ||= Time
						.parse(db
						.select(t:"stats", cols:"dl_time", where:where)
						.flatten.first)
				end
			end
		end
		module Calendar
			class Init
				attr_reader :user, :year, :db, :stars
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year), 
							   stars:)
					@user = Validate.user(u)
					@year = Validate.year(y)
					@stars = stars
					@db   = Query
						.new(path:Paths::Database.cfg(user))
						.table(t:"calendar", cols:cols)
				end
				def cols
					{ year: :INT,
					   day: :INT,
					 stars: :TEXT }
				end
				def n_stars(day)
					stars.keys.include?(day) ? stars[day] : 0
				end
				def day_data(day)
					["'#{year}'", "'#{day}'", "'#{n_stars(day)}'"]
				end
				def table_exist?
					db.select(t:"calendar", where:{year:"'#{year}'"}).count > 0
				end
				def insert
					unless table_exist?
						1.upto(25){|day| 
							db.insert(t:"calendar", 
									  val:day_data(day))}
					end
				end
			end
			class Part
				attr_reader :user, :year, :day, :db
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year),
							   d:Metafile.get(:day))
					@user = Validate.user(u)
					@year = Validate.year(y)
					@day  = Validate.day(d)
					@db   = Query.new(path:Paths::Database.cfg(user))
				end
				def get
					db.select(t:"calendar", cols:"stars", where:where)
						.flatten.first.to_i + 1
				end
				def where
					{ year:"'#{year}'",
					   day:"'#{day}'" }
				end
			end
			class Increment
				
			end
		end
	end 
end
#puts AocCli::Database::Calendar::Part.new(u: "google", y: 2020, d: 25).get
