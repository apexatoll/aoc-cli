module AocCli
module Day
	class Init
		attr_reader :year, :day, :user, :paths
		def initialize(user:Mf.get(:user), year:Mf.get(:year),
					    day:, dir:nil)
			@year = Val.year(year)
			@day  = Val.day(day)
			@user = Val.get_user(user)
			@paths = Files::Paths
				.new(user:user, year:year, day:day)
		end
		def mkdir
			raise Errors::DayExist if Dir.exist?(paths.day_dir)
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
			Files::Metafile
				.get_part(day:day, dir:year_dir_relative)
		end
		def year_dir_relative
			Files::Metafile.type == :ROOT ? "." : ".."
		end
	end
	class DayFiles 
		attr_reader :user, :year, :day, :cache, :files, :paths
		def initialize(user:Mf.get(:user), year:Mf.get(:year),
					    day:Mf.get(:day), files:[:Input, :Puzzle])
			@user  = Val.get_user(user)
			@year  = Val.year(year)
			@day   = Val.day(day)
			@cache = Cache::Query
				.new(user:user, year:year, day:day, files:files)
				.get
			@paths = Files::Paths
				.new(user:user, year:year, day:day)
		end
		def write
			cache.store.each{|page, data| data ? 
				File.write(paths.local_path(file:page), data) :
				download(page:page)}
		end
		private
		def download(page:, to:paths.paths(file:page))
			Object.const_get("AocCli::Day::Data::#{page}")
				.new(user:user, year:year, day:day)
				.write(to:to)
		end
	end
	module Data
		class DayObject
			attr_reader :user, :year, :day, :data, :paths
			def initialize(user:Mf.get(:user),
						   year:Mf.get(:year), day:)
				@user  = Val.get_user(user)
				@year  = Val.year(year)
				@day   = Val.day(day)
				@data  = parse(raw: fetch)
				@paths = Files::Paths.new(day:day)
			end
			def write(to:paths.paths(file:page))
				to.each{|path| File.write(path, data)}
			end
			private
			def fetch
				Tools::Get
					.new(user:user, year:year, day:day, page:page)
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
		attr_reader :year, :day
		def initialize(year:Mf.get(:year), day:Mf.get(:day))
			#@year = AocCli::Interface::Validate.year(year)
			#@day  = AocCli::Interface::Validate.day(day)
			@year = year
			@day = day
			@code = AocCli::Database::Query
				.new(name:"reddit.db")
				.select(table:"'#{year}'", 
						col:"day", val:"'#{day}'")
				.flatten[1]
		end
		def open
			system("#{cmd} #{link}")
		end
		def cmd
			["ttrv", "rtv"]
				.map{|cli| [cli, `which #{cli}`]}.to_h
				.reject{|cli, path| path.empty?}&.first ||= "open"
		end
		def link
			"https://www.reddit.com/r/"\
			"adventofcode/comments/#{code}/"\ 
			"#{year}_day_#{day}_solutions"
		end
	end
end end
#AocCli::Day::Reddit.new(year: 2018, day: 10).open
