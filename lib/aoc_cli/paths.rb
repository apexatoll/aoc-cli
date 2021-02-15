module AocCli
	module Paths
		class Config
			def self.create
				FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
				File.write(path, "", mode:"a") unless File
					.exist?(path)
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
				@user = Validate.user(u)
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
				Metafile.type == :DAY 
			end
			def day_dir
				day.to_i < 10 ? "0#{day}" : day.to_s
			end
			def local_dir
				in_day? ? "." : "#{day_dir}"
			end
			def cache_dir
				"#{Dir.home}/.cache/aoc-cli/"\
				"#{user}/#{year}/#{day_dir}" 
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
		end
		class Year
			attr_reader :user, :year
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year))
				@user = Validate.user(u)
				@year = Validate.year(y)
			end
			def in_year?
				File.exist?("./.meta") ? 
					Metafile.type == :ROOT : true
			end
			def year_dir
				in_year? ? "." : ".."
			end
			def local(f:)
				"#{Validate.not_init(dir:year_dir, 
					year:year)}/#{filename(f:f)}"
			end
			def filename(f:)
				case f.to_sym
				when :Stars then "#{year}.md"
				when :meta  then ".meta"
				end
			end
		end
		class Database < Config
			def self.dir
				"#{super}/db"
			end
			def self.cfg(name)
				FileUtils.mkdir_p(dir) unless Dir
					.exist?(dir)
				"#{dir}/#{name}.db"
			end
			def self.root(name)
				"#{__dir__}/db/#{name}.db"
			end
		end
	end
end
