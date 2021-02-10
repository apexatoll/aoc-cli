module AocCli
	module Day
		class Init
			attr_reader :year, :day, :user, :paths
			def initialize(day:,
					user:Files::Metafile.get(:user), 
					year:Files::Metafile.get(:year), dir:nil)
				@year = Interface::Validate.year(year)
				@day  = Interface::Validate.day(day)
				@user = user
				@paths = Files::Paths.new(user:user, year:year, day:day)
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
				Files::Metafile.get_part(day:day, dir:year_dir_relative)
			end
			def year_dir_relative
				Files::Metafile.type == :ROOT ? "." : ".."
			end
		end
		class DayFiles 
			attr_reader :user, :year, :day, :cache, :files, :paths
			def initialize(user:, year:, day:, files:[:Input, :Puzzle])
				@user  = user
				@year  = Interface::Validate.year(year)
				@day   = Interface::Validate.day(day)
				@cache = Cache::Query
					.new(user:user, year:year, day:day, files:files).get
				@paths = Files::Paths.new(user:user, year:year, day:day)
			end
			def write
				cache.store.each do |page, data|
					data ? 
						File.write(paths.local_path(file:page), data) :
						download(page:page)
				end
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
				def initialize(user:Files::Metafile.get(:user),
							   year:Files::Metafile.get(:year),
								day:)
					@paths = Files::Paths.new(day:day)
					@user  = user
					@year  = Interface::Validate.year(year)
					@day   = Interface::Validate.day(day)
					@data  = parse(raw: fetch)
				end
				def write(to:paths.paths(file:page))
					to.each{|path| File.write(path, data)}
				end
				private
				def fetch
					Tools::Get.new(user:user, year:year, day:day, page:page)
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
					raw.chunk(f:"<article", t:"<\/article", f_off:2).md
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
	end
end
