module AocCli
	module Day
		class Init
			attr_reader :year, :day, :user
			def initialize(day:,
					user:Files::Metafile.get(:user), 
					year:Files::Metafile.get(:year))
				@year = Interface::Validate.year(year)
				@day  = Interface::Validate.day(day)
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
			def dir
				day < 10 ? "0#{day}" : day.to_s
			end
			private
			def part
				Files::Metafile.get_part(day:day)
			end
			def meta
				<<~meta
				dir=>DAY
				day=>#{day}
				year=>#{year}
				user=>#{user}
				part=>#{part}
				meta
			end
		end
		module Data
			class DayObject
				attr_reader :user, :year, :day, :data
				def initialize(
					user:Files::Metafile.get(:user),
					year:Files::Metafile.get(:year),
					day:, dir:nil)
					@user = user
					@year = Interface::Validate.year(year)
					@day = Interface::Validate.day(day)
					@data = parse(raw: fetch)
					@dir = dir
				end
				def write
					puts "#{dir}/#{path}"
					File.write("#{dir}/#{path}", data)
				end
				def dir
					dir ||= get_dir
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
						#.gsub("\n\n\n", "\n")
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
