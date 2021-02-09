module AocCli
	module Day
		class Init
			attr_reader :year, :day, :user, :dir
			def initialize(day:,
					user:Files::Metafile.get(:user), 
					year:Files::Metafile.get(:year), dir:nil)
				@year = Interface::Validate.year(year)
				@day  = Interface::Validate.day(day)
				@dir  = dir ||= get_dir
				@user = user
			end
			def mkdir
				raise Errors::DayExist if Dir.exist?(dir)
				Dir.mkdir(dir)
				self
			end
			def write
				File.write("#{dir}/.meta", meta)
				self
			end
			def get_dir
				day < 10 ? "0#{day}" : day.to_s
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
		module Data
			class DayObject
				attr_reader :user, :year, :day, :data, :dir
				def initialize(
					user:Files::Metafile.get(:user),
					year:Files::Metafile.get(:year),
					day:, dir:nil)
					@user = user
					@year = Interface::Validate.year(year)
					@day = Interface::Validate.day(day)
					@data = parse(raw: fetch)
					#@dir = dir ||= get_dir
				end
				def write(paths:)
					paths.each{|p| File.write(p, data)}
					#File.write("#{dir}/#{path}", data)
				end
				protected
				def get_dir
					day.to_i < 10 ? "0#{day}" : day.to_s
				end
				private
				def fetch
					Tools::Get.new(user:user, year:year, day:day, page:page)
				end
				#def another_way
				#def dir
					#If you are in the day directory it writes to .
					#Else it writes to the day sub directory
					#Files::Metafile.type == :DAY ? "." : get_dir
				#end
			end
			class Puzzle < DayObject
				def page
					:puzzle
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
					:input
				end
				def parse(raw:)
					raw.raw
				end
				def path
					"input"
				end
			end
		end
		class DayFiles 
			extend AocCli::Cache::Query
			attr_reader :user, :year, :day, :cache
			def initialize(user:, year:, day:, pages:[:Input, :Puzzle])
				@user, @year, @day = user, year, day
				#@year = year
				#@day  = day
				#@user = Interface::Validate.user(user)
				#@year = Interface::Validate.year(year)
				#@day  = Interface::Validate.day(day)
				@cache = Cache::Query
					.new(user:user, year:year, day:day, pages:pages).get
			end
			def write
				cache.store.each do |page, data|
					if data
						#here the data is loaded from the cache
						#query and written to the day directory
						File.write(local_path(page:page), data)
					else
						#page.each do |p|
						download(page:p, paths:[cache.path(page:p), local_path(page:p)])
						#end
						#data.each{|d| }
						#here the data must be downloaded and stored in both the cache and the local dir
						puts "this file #{k} does not exist"
						puts "it shou#{cache.path(page:k)}"
						puts "and in #{local_path(page:k)}"
					end
				end
			end
			private
			def download(page:, paths:)
				Object.const_get("Day::Data::#{page}")
					.new(user:user, year:year, day:day)
					.write(paths:paths)
			end
			def local_path(page:)
				"#{dir}/#{cache.path(page:page)}"
			end
			def dir
				Files::Metafile.type == :DAY ? "." : day.to_i < 10 ?
					"0#{day}" : day.to_s
				#"."
			end
		end
	end
end
