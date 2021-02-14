module AocCli
	module Day
		def self.refresh
			puts "- Updating puzzle...".yellow
			Init.new.write
			Data::Puzzle.new.write
		end
		class Init
			attr_reader :year, :day, :user, :paths
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year), 
						   d:Metafile.get(:day))
				@user  = Validate.user(u)
				@year  = Validate.year(y)
				@day   = Validate.day(d)
				@paths = Paths::Day.new(u:user, y:year, d:day)
			end
			def mkdir
				Dir.mkdir(Validate.day_dir(paths.day_dir))
				self
			end
			def write
				File.write(paths.local(f:"meta"),
					Metafile.day(u:user, y:year, d:day))
				self
			end
		end
		class Pages < Init
			attr_reader :cache, :files
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day), 
						   f:[:Input, :Puzzle])
				super(u:u, y:y, d:d)
				@files = f
			end
			def write
				cache.each{|page, data| data ? 
					File.write(paths.local(f:page), data) : 
					download(page:page)}
			end
			private
			def cache
				@cache ||= Cache
					.new(u:user, y:year, d:day, f:files).load
			end
			def download(page:, to:paths.cache_and_local(f:page))
				Object.const_get("AocCli::Day::Data::#{page}")
					.new(u:user, y:year, d:day)
					.write(to:to)
			end
		end
		module Data
			class DayObject < Init
				attr_reader :user, :year, :day, :data, :paths
				def initialize(u:Metafile.get(:user), 
							   y:Metafile.get(:year),
							   d:Metafile.get(:day))
					super(u:u, y:y, d:d)
					@data  = parse(raw: fetch)
				end
				def write(to:paths.cache_and_local(f:page))
					to.each{|path| File.write(path, data)}
				end
				private
				def fetch
					Tools::Get.new(u:user, y:year, d:day, p:page)
				end
			end
			class Puzzle < DayObject
				def page
					:Puzzle
				end
				def parse(raw:)
					raw.chunk(f:"<article", t:"<\/article", f_off:2)
						.md
						.gsub(/(?<=\])\[\]/, "")
						.gsub(/\n.*<!--.*-->.*\n/, "")
				end
			end
			class Input < DayObject
				def page
					:Input
				end
				def parse(raw:)
					raw.raw
				end
			end
		end
		class Cache < Pages
			require 'fileutils'
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   f:[:Input, :Puzzle])
				super(u:u, y:y, d:d, f:f)
				FileUtils.mkdir_p(paths.cache_dir) unless Dir
					.exist?(paths.cache_dir)
			end
			def load
				files.map{|f| [f, read_file(f:f)]}.to_h
			end
			private
			def read_file(f:)
				cached?(f:f) ? read(f:f) : nil
			end
			def cached?(f:)
				File.exist?(paths.cache_path(f:f))
			end
			def read(f:)
				File.read(paths.cache_path(f:f))
			end
		end
		class Reddit
			attr_reader :year, :day, :uniq
			def initialize(y:Metafile.get(:year), 
						   d:Metafile.get(:day))
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@uniq = Database::Query
					.new(path:Paths::Database.root("reddit"))
					.select(t:"'#{year}'", data:{day:"'#{day}'"})
					.flatten[1]
			end
			def open
				system("#{cmd} #{link}")
			end
			def cmd
				["ttrv", "rtv"]
					.map{|cli| cli unless `which #{cli}`.empty?}
					.reject{|cmd| cmd.nil?}&.first || "open"
			end
			def link
				"https://www.reddit.com/r/"\
				"adventofcode/comments/#{uniq}/"\
				"#{year}_day_#{day}_solutions"
			end
		end
		class AttemptsTable < Init
			require 'terminal-table'
			attr_reader :part, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part))
				super(u:u, y:y, d:d)
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
	end
end
