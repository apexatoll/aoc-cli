#require 'aoc_cli'
module AocCli
	module Files
		class Config
			def initialize
				Paths::Config.create
			end
			def default_alias
				is_set?(key:"default") ? get_line(key:"default") : nil || 
				is_set?(key:"cookie=>main") ? "main" : nil ||
				get_line(key:"cookie")&.gsub(/=>.*/, "")
			end
			def is_set?(key:nil, val:nil)
				read.split("\n").grep(/(?<!\/\/)#{key}=>#{val}/).any?
			end
			def mod_line(key:, val:)
				is_set?(key:key) ?
					write(f:read.gsub(/(?<=^#{key}=>).*$/, val.to_s)) :
					write(f:"#{key} => #{val}\n", m:"a")
			end
			def get_line(key:)
				read.scan(/(?:(?<=(?<!\/\/)#{key}=>)).*$/)&.first
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
		class Setting < Config
			def bool(key:, default:)
				is_set?(key:key) ?
					get_bool(key:key) : default
			end
			def string
				is_set?(key:key) ?
					get_line(key:key) : default
			end
		end
		class Cookie < Config
			attr_reader :user
			def initialize(u:)
				@user = u
				super()
			end
			def store(key:)
				puts user
				set_line(key:"cookie=>#{Validate.set_user(user)}",
						 val:Validate.set_key(key))
			end
			def key
				Validate.key(get_line(key:"cookie=>#{user}"))
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
			def self.part(u:Metafile.get(:user),
						  y:Metafile.get(:year),
						  d:)
				Database::Calendar::Part.new(d:d).get
			end
			private
			def self.read(dir:".")
				File.read("#{Validate.init(dir)}/.meta")
			end
			#def self.root_dir
				#type == :ROOT ? "." : ".."
			#end
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
				part=>#{part(u:u, y:y, d:d)}
				meta
			end
		end
		class Calendar
			attr_reader :cal, :stats, :year
			def initialize(y:Metafile.get(:year),
						   cal:nil, stats:nil)
				@year = Validate.year(y)
				@cal = cal
				@stats = stats
			end
			def include_stats?
				Setting.new.bool(key:"lb_in_calendar", default:true)
			end
			def title
				"Year #{year}: #{stats.total_stars}/50 *"
			end
			def underline
				"-" * (cal.data[0].to_s.length + 2)
			end
			def file
				<<~file
					#{title}
					#{underline}
					#{cal.data.join("\n")}\n
					#{stats.data.join("\n") if stats.total_stars > 0 &&
						include_stats?}
				file
			end
		end
	end 
end
#puts AocCli::Files::Calendar.new.include_stats?
