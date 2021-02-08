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
					@dir = dir ||= get_dir
				end
				def write
					File.write("#{dir}/#{path}", data)
				end
				protected
				def get_dir
					day.to_i < 10 ? "0#{day}" : day.to_s
				end
				private
				def fetch
					Tools::Get.new(user:user, year:year, day:day, page:page)
				end
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
	end
end
