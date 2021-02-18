module AocCli
	module Day
		def self.refresh
			puts "- Updating puzzle...".yellow
			Init.new.meta
			Data::Puzzle.new.write
		end
		class Init
			attr_reader :year, :day, :user, :paths, :part
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
			def meta
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
				dl = Object.const_get("AocCli::Day::Data::#{page}")
					.new(u:user, y:year, d:day)
					.write(to:to)
				dl.init_db if dl.class
					.instance_methods
					.include?(:init_db)
			end
		end
		module Data
			class DayObject < Init
				attr_reader :user, :year, :day, :data, :paths, :part
				def initialize(u:Metafile.get(:user), 
							   y:Metafile.get(:year),
							   d:Metafile.get(:day))
					super(u:u, y:y, d:d)
					@part = Metafile.part(d:day)
					@data  = parse(raw: fetch)
				end
				def write(to:paths.cache_and_local(f:page))
					to.each{|path| File.write(path, data)}
					self
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
				def init_db
					Database::Stats::Init
						.new(d:day, p:part)
						.init if part < 3
					self
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
			attr_reader :year, :day, :uniq, :browser
			def initialize(y:Metafile.get(:year), 
						   d:Metafile.get(:day),
						   b:false)
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@uniq = Database::Query
					.new(path:Paths::Database.root("reddit"))
					.select(t:"'#{year}'", data:{day:"'#{day}'"})
					.flatten[1]
				@browser = b
			end
			def open
				system("#{browser ? "open" : cmd} #{link}")
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
	end
end
