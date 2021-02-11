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
			set_line(key:"cookie=>#{Val.set_user(user)}",
					 val:Val.set_key(key))
		end
		def key
			get_line(key:"cookie=>#{Val.get_user(user)}",
					 val:Val.get_key(key))
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
			raise E::NotInit unless File.exist?(path(dir:dir))
			File.read(path(dir:dir))
		end
		def self.path(dir:".")
			"#{dir}/.meta"
		end
	end
	class Paths
		attr_reader :user, :year, :day
		def initialize(user:Mf.get(:user), 
					   year:Mf.get(:year), day:)
			@user = Val.set?(k: :u, v:user)
			@year = Val.year(year)
			@day  = Val.day(day)
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
			"lib/aoc_cli/db/#{db}"
		end
	end
end end
