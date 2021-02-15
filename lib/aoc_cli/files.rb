module AocCli
	module Files
		class Config
			require 'fileutils'
			def initialize
				Paths::Config.create
			end
			def def_acc
				get_line(key:"default") || "main"
			end
			def is_set?(key:nil, val:nil)
				read.split("\n").grep(/#{key}=>#{val}/).any?
			end
			def mod_line(key:, val:)
				is_set?(key:key) ?
					write(f:read.gsub(/(?<=^#{key}=>).*$/, 
						  val.to_s)) :
					write(f:"#{key}=>#{val}\n", m:"a")
			end
			def get_line(key:)
				read.scan(/(?<=#{key}=>).*$/)&.first
			end
			def get_bool(key:)
				get_line(key:key) == "true" ? true : false
			end
			protected
			def set_line(key:, val:)
				write(f:"#{key}=>#{val}\n", m:"a")
			end
			private
			def read
				File.read(Paths::Config.path)
			end
			def write(f:, m:"w")
				File.write(Paths::Config.path, f, mode:m)
			end
		end
		class Cookie < Config
			attr_reader :user
			def initialize(u:)
				@user = u
				super()
			end
			def store(key:)
				set_line(key:"cookie=>#{Validate.set_user(user)}",
						 val:Validate.set_key(key))
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
			def self.add(hash:, path:".meta")
				hash.map {|k, v| "#{k}=>#{v}\n"}
					.each{|l| File.write(path, l, mode:"a")}
			end
			def self.part(d:)
				JSON.parse(read(dir:root_dir)
					.scan(/(?<=stars=>).*$/)&.first)[d.to_s]
					.to_i + 1
			end
			private
			def self.read(dir:".")
				File.read("#{Validate.init(dir)}/.meta")
			end
			def self.root_dir
				type == :ROOT ? "." : ".."
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
	end 
end
