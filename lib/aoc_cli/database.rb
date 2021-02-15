#require 'aoc_cli'
module AocCli
	module Database
		class Query
			require 'sqlite3'
			attr_reader :db
			def initialize(path:)
				@db = SQLite3::Database.open(path)
			end
			def select(t:, cols:"*", data:)
				db.execute(
				"SELECT #{cols} FROM #{t} "\
				"WHERE #{data.map{|k, v| "#{k} = #{v}"}.join(" AND ")}")
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
					.cfg("attempts"))
					.table(t:attempt.user, cols:cols)
			end
			def correct
				db.insert(t:attempt.user, 
						  val:data << 1 << 0 << 0)
			end
			def incorrect(high:, low:)
				db.insert(t:attempt.user, val:data.push(0)
					.push(parse_hi_lo(high:high, low:low)))
			end
			def parse_hi_lo(high:, low:)
				[high ? 1 : 0, low ? 1 : 0]
			end
			def data
				["'#{Time.now}'",
				 "'#{attempt.year}'",
				 "'#{attempt.day}'",
				 "'#{attempt.part}'",
				 "'#{attempt.answer}'"]
			end
			def cols
				{"time"=>:TEXT, 
				 "year"=>:INT, 
				 "day"=>:INT, 
				 "part"=>:INT, 
				 "answer"=>:TEXT, 
				 "correct"=>:INT,
				 "low"=>:INT,
				 "high"=>:INT}
			end
		end
		class PuzzleStats
			attr_reader :user, :year, :day, :part, :now, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part))
				@user = Validate.user(u)
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@part = Validate.part(p)
				@now  = Time.now
				@db   = Query.new(path:Paths::Database.cfg("#{user}air"))
							 .table(t:"stats", cols:cols)
			end
			def init
				db.insert(t:"stats", val:data)
			end
			def data
				["'#{year}'",
				 "'#{day}'",
				 "'#{part}'",
				 "'#{now}'",
				 "NULL",
				 "NULL",
				 "'0'",
				 "'0'"]
			end
			def cols
				    {year: :INT, 
				      day: :INT, 
				     part: :INT, 
				  dl_time: :TEXT,
				 end_time: :TEXT,
				  elapsed: :TEXT,
				 attempts: :INT,
				  correct: :INT}
			end
		end
		class PuzzleComplete < PuzzleStats
			attr_reader :attempts
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part),
						   attempts:)
				super(u:u, y:y, d:d, p:p)
				@attempts = attempts
			end
			def elapsed
				@elapsed ||= hms(now - dl_time)
			end
			def dl_time
				@dl_time ||= 
					Time.parse(db
						.select(t:"stats", cols:"dl_time", data:where)
						.flatten.first)
			end
			def where
				{year:year,
				  day:day, 
				 part:part}
			end
			def val
				{ elapsed:"'#{elapsed}'", 
				 end_time:"'#{now}'", 
				 attempts:"'#{attempts}'"}
			end
			def hms(seconds)
				[seconds/3600, seconds/60 % 60, seconds % 60]
					.map{|t| t.to_i.to_s.rjust(2, "0")}.join(":")
			end
			def update
				db.update(t:"stats", val:val, where:where)
			end
		end
	end
end 

#AocCli::Database::PuzzleStats
	#.new(u: "test", y: 2019, d: 5, p: 2).init
#AocCli::Database::PuzzleComplete
	#.new(u: "test", y: 2019, d: 5, p: 2, attempts: 3)
	#.update
