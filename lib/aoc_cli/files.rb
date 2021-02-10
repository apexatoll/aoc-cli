module AocCli
	module Files
		class Config
			require 'fileutils'
			def initialize
				FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
				File.write(path, "", mode:"a") unless File.exist?(path)
			end
			protected
			def has_term?(key:nil, val:nil)
				file.split("\n").grep(/#{key}=>#{val}/).any?
			end
			def add_line(key:, val:)
				File.write(path, "#{key}=>#{val}\n", mode:"a")
			end
			def file
				File.read(path)
			end
			def dir
				"#{Dir.home}/.config/aoc-cli"
			end
			def path
				"#{dir}/aoc.rc"
			end
		end
		class Cookie < Config
			attr_reader :user, :key
			def initialize(user:)
				@user = user
				super()
			end
			def store(key:)
				raise Errors::Key_Nil if key.nil?
				raise Errors::UserDup if has_term?(key:"cookie=>#{user}")
				raise Errors::KeyDup  if has_term?(val:key)
				add_line(key:"cookie=>#{user}", val:key)
			end
			def key
				file.scan(/(?<=cookie=>#{user}=>).*$/)&.first ||= 
					raise(Errors::Key_Not_Found)
			end
		end
		class Metafile
			def self.get(field)
				read.scan(/(?<=#{field}=>).*$/)&.first&.chomp
			end
			def self.type
				read.scan(/(?<=dir=>).[A-Z]*$/).first.to_sym
			end
			def self.add(hash:, dir:".")
				hash.map {|k, v| "#{k}=>#{v}\n"}
					.each{|l| File.write("#{dir}/#{path}",l , mode:"a")}
			end
			def self.get_part(day:, dir:".")
				JSON.parse(read(dir:dir).scan(/(?<=stars=>).*$/)
					&.first)[day.to_s].to_i + 1
			end
			private
			def self.read(dir:".")
				raise Errors::NotInit unless File.exist?(path(dir:dir))
				File.read(path(dir:dir))
			end
			def self.path(dir:".")
				"#{dir}/.meta"
			end
		end
		class Paths
			attr_reader :user, :year, :day
			def initialize(user:Metafile.get(:user), 
						   year:Metafile.get(:year), day:)
				@user = user
				@year = Interface::Validate.year(year)
				@day  = Interface::Validate.day(day)
			end
			def filename(file:)
				case file
				when :Input  then "input"
				when :Puzzle then "#{day}.md"
				end 
			end
			def in_day?
				Metafile.type == :DAY 
			end
			def in_root?
				Metafile.type == :ROOT
			end
			def day_dir
				day.to_i < 10 ? "0#{day}" : day.to_s
			end
			def local_dir
				in_day? ? "." : "#{day_dir}"
			end
			def cache_dir
				"#{Dir.home}/.cache/aoc-cli/#{user}/#{year}/#{day_dir}" 
			end
			def local_path(file:)
				"#{local_dir}/#{filename(file:file)}"
			end
			def cache_path(file:)
				"#{cache_dir}/#{filename(file:file)}"
			end
			def paths(file:)
				[cache_path(file:file), local_path(file:file)]
			end
			def year_meta
				in_day? ? "../meta" : ".meta"
			end
			def day_meta
				in_day? ? ".meta" : "#{day_dir}/.meta"
			end
		end
	end
end
