module AocCli
	module Files
		class Config
			require 'fileutils'
			def initialize
				FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
				File.write(path, "", mode:"a") unless File.exist?(path)
			end
			def def_acc
				get_line(key:"default") || "main"
			end
			def is_set?(key:nil, val:nil)
				file.split("\n").grep(/#{key}=>#{val}/).any?
			end
			protected
			def get_line(key:)
				file.scan(/(?<=#{key}=>).*$/)&.first
			end
			def set_line(key:, val:)
				File.write(path, "#{key}=>#{val}\n", mode:"a")
			end
			def change_line(key:, val:)
				is_set?(key:key) ?
					File.write(path, file
						.gsub(/^(?<=#{key}=>).*$/, "#{val}")) :
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
			def initialize(u:)
				@user = u
				super()
			end
			def store(key:)
				set_line(key:"cookie=>#{Val.set_user(user)}",
						 val:Val.set_key(key))
			end
			def key
				get_line(key:"cookie=>#{user}")
			end
		end
		class Metafile
			def self.get(field)
				read.scan(/(?<=#{field}=>).*$/)&.first&.chomp
			end
			def self.type
				get("dir").to_sym
			end
			def self.add(hash:, dir:".")
				hash.map {|k, v| "#{k}=>#{v}\n"}
					.each{|l| File.write("#{dir}/#{path}",l , mode:"a")}
			end
			private
			def self.write()

			end
			def self.read(dir:".")
				File.read("#{Validate.init(dir)}/.meta")
			end
			def self.root_dir
				type == :ROOT ? "." : ".."
			end
			def self.part(d:)
				JSON.parse(read(dir:root_dir)
					.scan(/(?<=stars=>).*$/)&.first)[d.to_s]
					.to_i + 1
			end
			def self.year(u:, y:)
				<<~meta
				dir=>ROOT
				user=>#{u}
				year=>#{y}
				meta
			end
			def self.day(u:, y:, d:)
				<<~meta
				dir=>DAY
				user=>#{u}
				year=>#{y}
				day=>#{d}
				part=>#{part(d:d)}
				meta
			end
		end
		module Paths
			class Day
				attr_reader :user, :year, :day
				def initialize(u:Metafile.get(:user), 
							   y:Metafile.get(:year), d:)
					@user = Validate.set?(k: :u, v:u)
					@year = Validate.year(y)
					@day  = Validate.day(d)
				end
				def filename(f:)
					case f
					when :Input  then "input"
					when :Puzzle then "#{day}.md"
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
					"#{Dir.home}/.cache/aoc-cli/#{user}/#{year}/#{day_dir}" 
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
				def year_meta
					in_day? ? "../meta" : ".meta"
				end
				def day_meta
					in_day? ? ".meta" : "#{day_dir}/.meta"
				end
			end
		end
		class Database
			require 'sqlite3'
			attr_reader :db
			def initialize(db:)
				@db = SQLite3::Database.open(path(db:db))
			end
			def select(table:, col:nil, val:nil)
				db.execute("SELECT * FROM #{table}"\
						   "WHERE #{col} = #{val}")
			end
			def path(db:)
				"#{__dir__}/db/#{db}"
			end
		end
	end 
end
