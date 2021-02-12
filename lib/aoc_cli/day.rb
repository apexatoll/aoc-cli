module AocCli
	module Day
		class Init
			attr_reader :year, :day, :user, :paths
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year), 
						   d:, dir:nil)
				@user  = Validate.get_user(u)
				@year  = Validate.year(y)
				@day   = Validate.day(d)
				@paths = AocCli::Files::Paths
					.new(u:user, y:year, d:day)
			end
			def mkdir
				raise E::DayExist if Dir.exist?(paths.day_dir)
				Dir.mkdir(paths.day_dir)
				self
			end
			def write
				File.write("#{paths.local_dir}/.meta", meta)
				self
			end
			private
			def meta
				<<~meta
				dir=>DAY
				day=>#{day}
				year=>#{year}
				user=>#{user}
				part=>#{part}
				meta
			end
			def part
				Metafile.get_part(d:day, dir:root_dir)
			end
			def root_dir
				Metafile.type == :ROOT ? "." : ".."
			end
		end
		class Files 
			attr_reader :user, :year, :day, :cache, :files, :paths
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day), 
						   f:[:Input, :Puzzle])
				@user  = Validate.get_user(u)
				@year  = Validate.year(y)
				@day   = Validate.day(d)
				@files = f
				@cache = Cache::Query
					.new(u:user, y:year, d:day, f:files).get
				@paths = AocCli::Files::Paths
					.new(u:user, y:year, d:day)
			end
			def write
				cache.store.each{|page, data| data ? 
					File.write(paths.local_path(file:page), data) : download(page:page)}
			end
			private
			def download(page:, to:paths.paths(file:page))
				Object.const_get("AocCli::Day::Data::#{page}")
					.new(u:user, y:year, d:day)
					.write(to:to)
			end
		end
		module Data
			class DayObject
				attr_reader :user, :year, :day, :data, :paths
				def initialize(u:Metafile.get(:user),
							   y:Metafile.get(:year), d:)
					@user  = Validate.get_user(u)
					@year  = Validate.year(y)
					@day   = Validate.day(d)
					@paths = AocCli::Files::Paths.new(d:day)
					@data  = parse(raw: fetch)
				end
				def write(to:paths.paths(file:page))
					to.each{|path| File.write(path, data)}
				end
				private
				def fetch
					Tools::Get
						.new(u:user, y:year, d:day, page:page)
				end
			end
			class Puzzle < DayObject
				def page
					:Puzzle
				end
				def path
					"#{day}.md"
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
				def path
					"input"
				end
			end
		end
		class Reddit
			attr_reader :year, :day, :code
			def initialize(y:Metafile.get(:year), 
						   d:Metafile.get(:day))
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@code = AocCli::Files::Database
					.new(db:"reddit.db")
					.select(table:"'#{year}'", 
							col:"day", val:"'#{day}'")
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
				"adventofcode/comments/#{code}/"\
				"#{year}_day_#{day}_solutions"
			end
		end
	end
end
