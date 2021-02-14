module AocCli
	module Files
		class Config
			require 'fileutils'
			def initialize
				Paths::Config.create
			end
			def def_acc
				get_line(key:"default") || "main"
			end
			def is_set?(key:nil, val:nil)
				read.split("\n").grep(/#{key}=>#{val}/).any?
			end
			protected
			def get_line(key:)
				read.scan(/(?<=#{key}=>).*$/)&.first
			end
			def set_line(key:, val:)
				write(f:"#{key}=>#{val}\n", m:"a")
			end
			def mod_line(key:, val:)
				is_set?(key:key) ?
					write(f:read.gsub(/^(?<=#{key}=>).*$/, val.to_s)) :
					write(f:"#{key}=>#{val}\n", m:"a")
			end
			private
			def read
				File.read(Paths::Config.path)
			end
			def write(f:, m:"w")
				File.write(Paths::Config.path, f, mode:m)
			end
		end
		class Cookie < Config
			attr_reader :user
			def initialize(u:)
				@user = u
				super()
			end
			def store(key:)
				set_line(key:"cookie=>#{Validate.set_user(user)}",
						 val:Validate.set_key(key))
			end
			def key
				get_line(key:"cookie=>#{user}")
			end
		end
		class Metafile
			def self.get(field)
				read.scan(/(?<=#{field}=>).*$/)&.first&.chomp
			end
			def self.type
				get("dir").to_sym
			end
			def self.add(hash:, path:".meta")
				hash.map {|k, v| "#{k}=>#{v}\n"}
					.each{|l| File.write(path, l, mode:"a")}
			end
			private
			def self.read(dir:".")
				File.read("#{Validate.init(dir)}/.meta")
			end
			def self.root_dir
				type == :ROOT ? "." : ".."
			end
			def self.part(d:)
				JSON.parse(read(dir:root_dir)
					.scan(/(?<=stars=>).*$/)&.first)[d.to_s]
					.to_i + 1
			end
			def self.year(u:, y:)
				<<~meta
				dir=>ROOT
				user=>#{u}
				year=>#{y}
				meta
			end
			def self.day(u:, y:, d:)
				<<~meta
				dir=>DAY
				user=>#{u}
				year=>#{y}
				day=>#{d}
				part=>#{part(d:d)}
				meta
			end
		end
		module Paths
			class Config
				def self.create
					FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
					File.write(path, "", mode:"a") unless File.exist?(path)
				end
				def self.dir
					"#{Dir.home}/.config/aoc-cli"
				end
				def self.path
					"#{dir}/aoc.rc"
				end
			end
			class Day
				attr_reader :user, :year, :day
				def initialize(u:Metafile.get(:user), 
							   y:Metafile.get(:year), d:)
					@user = Validate.set?(k: :u, v:u)
					@year = Validate.year(y)
					@day  = Validate.day(d)
				end
				def filename(f:)
					case f.to_sym
					when :Input  then "input"
					when :Puzzle then "#{day}.md"
					when :meta   then ".meta"
					end 
				end
				def in_day?
					puts Metafile.type
					Metafile.type == :DAY 
				end
				def day_dir
					day.to_i < 10 ? "0#{day}" : day.to_s
				end
				def local_dir
					in_day? ? "." : "#{day_dir}"
				end
				def cache_dir
					"#{Dir.home}/.cache/aoc-cli/#{user}/#{year}/#{day_dir}" 
				end
				def local(f:)
					"#{local_dir}/#{filename(f:f)}"
				end
				def cache_path(f:)
					"#{cache_dir}/#{filename(f:f)}"
				end
				def cache_and_local(f:)
					[cache_path(f:f), local(f:f)]
				end
				def year_meta
					in_day? ? "../meta" : ".meta"
				end
				def day_meta
					in_day? ? ".meta" : "#{day_dir}/.meta"
				end
			end
			class Year
				attr_reader :user, :year
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year))
					@user = Validate.user(u)
					@year = Validate.year(y)
				end
				def in_year?
					File.exist?("./.meta") ? Metafile.type == :ROOT : true
				end
				def year_dir
					in_year? ? "." : ".."
				end
				def local(f:)
					puts in_year?
					"#{Validate.not_init(dir:year_dir, year:year)}/#{filename(f:f)}"
				end
				def filename(f:)
					case f.to_sym
					when :Stars then "#{year}.md"
					when :meta  then ".meta"
					end
				end
			end
		end
		module Database
			class Query
				require 'sqlite3'
				attr_reader :db
				def initialize(db:)
					puts path(db:db)
					@db = SQLite3::Database.open(path(db:db))
				end
				#def select(table:, cols:"*", col:nil, val:nil)
				def select(t:, cols:"*", data:)
					str = "SELECT #{cols} FROM #{t} "\
						"WHERE #{data.map{|k, v| "#{k} = #{v}"}.join(" AND ")}"
						#"SELECT #{cols} FROM #{table}"\
						#"rrWHERE #{col} = #{val}")
					puts str
					db.execute(str)
				end
				def table(t:, cols:)
					sql = cols.map{|c, t| "#{c} #{t}"}.join(", ")
					db.execute(
						"CREATE TABLE IF NOT EXISTS "\
						"#{t}(#{sql})")
					self
				end
				def insert(t:, val:)
					db.execute(
						"INSERT INTO #{t} "\
						"VALUES(#{val.join(", ")})")
					self
				end
				def path(db:)
					"#{__dir__}/db/#{db}"
				end
			end
			class Log
				attr_reader :attempt, :db
				def initialize(attempt:)
					@attempt = attempt
					@db = Query.new(db:"attempts.db")
						.table(t:attempt.user, cols:cols)
				end
				def correct
					db.insert(t:attempt.user, val:data << 1)
				end
				def incorrect
					db.insert(t:attempt.user, val:data << 0)
				end
				def data
					["'#{Time.now}'",
					 "'#{attempt.year}'",
					 "'#{attempt.day}'",
					 "'#{attempt.part}'",
					 "#{attempt.answer}"]
				end
				def cols
					{"time"=>:TEXT, 
					 "year"=>:INT, 
					 "day"=>:INT, 
					 "part"=>:INT, 
					 "answer"=>:TEXT, 
					 "correct"=>:INT}
				end
			end
		end
	end 
end

#Attempt = Struct.new(:user, :year, :day, :part, :answer)
#test = Attempt.new("main", 2020, 10, 1, 12343)
#AocCli::Files::Database::Log.new(attempt: test).incorrect
#data = {year: '2020', day: '10', part: '1', correct: '1'}
#time = AocCli::Files::Database::Query.new(db: "attempts.db").select(t: "main", cols: "time", data: data).first.first
#puts time
#
#DateTime.strptime(time, "%Y-%m-%d %H:%M:%S %Z")
					#puts val
