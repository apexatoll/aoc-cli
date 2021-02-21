module AocCli
	module Day
		class Init
			attr_reader :user, :year, :day, :paths
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
			attr_reader :files, :use_cache
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day), 
						   f:[:Input, :Puzzle],
						   use_cache:true)
				super(u:u, y:y, d:d)
				@files = f
				@use_cache = use_cache
			end
			def load
				files.each do |file| use_cache && cache[file] ?
					copy(file:file) : download(page:file) end
			end
			def cache
				@cache ||= Cache.new(d:day, f:files).query
			end
			def copy(file:)
				File.write(paths.local(f:file), cache[file])
			end
			def download(page:)
				req = Requests.const_get(page)
					.new(u:user, y:year, d:day)
					.write(to:paths.cache_and_local(f:page))
				req.init_stats if page == :Puzzle
			end
		end
		class Cache < Pages
			def initialize(u:Metafile.get(:user), 
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   f:[:Input, :Puzzle])
				super(u:u, y:y, d:d, f:f)
				paths.create_cache
			end
			def query
				files.map{|file| [file, read(file:file)]}.to_h
			end
			private
			def read(file:)
				File.exist?(paths.cache_path(f:file)) ?
					File.read(paths.cache_path(f:file)) : nil
			end
		end
		module Requests
			class Request < Init
				attr_reader :data, :part
				def initialize(u:Metafile.get(:user), 
							   y:Metafile.get(:year),
							   d:Metafile.get(:day))
					super(u:u, y:y, d:d)
					@data = parse(raw:fetch)
					@part = Metafile.part(d:day)
				end
				def write(to:)
					to.each{|path| File.write(path, data)}; self
				end
				private
				def fetch
					Tools::Get.new(u:user, y:year, d:day, p:page)
				end
			end
			class Puzzle < Request
				def page
					:Puzzle
				end
				def parse(raw:fetch)
					raw.chunk(f:"<article", t:"<\/article", f_off:2)
						.md
						.gsub(/(?<=\])\[\]/, "")
						.gsub(/\n.*<!--.*-->.*\n/, "")
				end
				def init_stats
					Database::Stats::Init
						.new(d:day, p:part)
						.init if part < 3 && !stats_exist?
				end
				def stats_exist?
					Database::Query
						.new(path:Paths::Database.cfg(user))
						.select(t:"stats", 
								where:{year:year, day:day, part:part})
						.count > 0
				end
			end
			class Input < Request
				def page
					:Input
				end
				def parse(raw:fetch)
					raw.raw
				end
			end
		end
		def self.refresh(files:[:Input, :Puzzle])
			puts "- Updating puzzle...".blue
			Init.new.meta
			Pages.new(f:files, use_cache:false).load
		end
	end
end
